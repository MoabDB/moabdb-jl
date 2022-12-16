# MoabDB

module MoabDB

using Dates
using ProtoBuf
using Base64
using HTTP
using PyCall
import Pandas
import DataFrames

include("moabdb_pb.jl")

function get_equity(ticker::String, start::DateTime, length, intraday::Bool=false, username::String="", password::String="")
    end_time = start + length
    get_equity(ticker, start, end_time, intraday, username, password)
end

function get_equity(ticker::String, length, end_time::DateTime, intraday::Bool=false, username::String="", password::String="")
    start = end_time - length
    get_equity(ticker, start, end_time, intraday, username, password)
end

function get_equity(ticker::String, length, intraday::Bool=false, username::String="", password::String="")
    end_time = now()
    start = end_time - length
    get_equity(ticker, start, end_time, intraday, username, password)
end

function get_equity(ticker::String, start::DateTime, end_time::DateTime, intraday::Bool=false, username::String="", password::String="")
    start = floor(Int, datetime2unix(start));
    end_time = floor(Int, datetime2unix(end_time));

    db = "daily_stocks"
    if intraday
        db = "intraday_stocks"
    end

    r = moabdb_pb.Request(ticker, db, start, end_time, username, password);
    io = IOBuffer();
    e = ProtoEncoder(io);
    encode(e, r);
    seekstart(io);

    bio = IOBuffer();
    iob64_encode = Base64EncodePipe(bio);
    write(iob64_encode, io)
    close(iob64_encode);
    str = String(take!(bio))

    res = HTTP.request("GET", "https://api.moabdb.com/request/v1/", ["x-req" => str])
    if res.status != 200
        throw(res.status)
    end

    dio = base64decode(String(res.body))
    dio = IOBuffer(dio)
    d = ProtoDecoder(dio);
    r = decode(d, moabdb_pb.Response)

    if r.code != 200
        throw(r.message)
    end

    pyio_import = pyimport("io")
    python_io = pyio_import.BytesIO(r.data)
    df = Pandas.read_parquet(python_io)

    python_io = 0

    df = DataFrames.DataFrame(df)
    if intraday
        df = DataFrames.select!(df, :symbol, :time, :price, :bid, :ask, :volume)
    else
        df = DataFrames.select!(df, :symbol, :date, :open, :low, :high, :close, :volume)
        df[!,:volume] = DataFrames.convert(Vector{Int64},df[!,:volume])
    end

    return df
end

end # module moabdb
