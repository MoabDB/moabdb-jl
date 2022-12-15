# MoabDB

module MoabDB

using Dates
using ProtoBuf
using Base64
using HTTP

include("moabdb_pb.jl")

function about()
    println("Thank you for your interest in MoabDB's Julia library!")
    println("Unfortunately, this library is very much under stale construction.")
    println()
    println("The current blocking issue is https://github.com/JuliaIO/Parquet.jl/issues/145")
    println("Other options that also won't work are as follows:")
    println("https://github.com/JuliaPy/Pandas.jl cannot read from bytes")
    println("https://expandingman.gitlab.io/Parquet2.jl cannot read from bytes")
    println("https://github.com/pola-rs/polars/issues/547 has no Julia interface")
    println()
    println("From a high level perspective, the best outcome is a complete Julia interface of Polars")
    println("Until the MoabDB team develops an alternative or the JuliaIO team fixes this, please use our Python or Rust library.")
    println("Contributions are open under our GitHub repo, sorry for the inconvenience.")
end

function get_equity(ticker::String, start::DateTime, end_time::DateTime)
    get_equity(ticker, start, end_time, false, "", "")
end

function get_equity(ticker::String, start::DateTime, end_time::DateTime, intraday::Bool, username::String, password::String)
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

    return r.data
end

end # module moabdb
