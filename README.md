# MoabDB for Julia

Thank you for your interest in MoabDB's Julia library!
Unfortunately, this library is very much under stale construction.

The current blocking issue is https://github.com/JuliaIO/Parquet.jl/issues/145

Other options that also won't work are as follows:
- https://github.com/JuliaPy/Pandas.jl cannot read from bytes
- https://expandingman.gitlab.io/Parquet2.jl cannot read from bytes
- https://github.com/pola-rs/polars/issues/547 has no Julia interface

From a high level perspective, the best outcome is a complete Julia interface of Polars
Until the MoabDB team develops an alternative or the JuliaIO team fixes this, please use our Python or Rust library.
Contributions are open under our GitHub repo, sorry for the inconvenience.

# Meanwhile
This library will return the raw bytes for a Parquet to parse how'd you like.
The package name ``MoabDB`` cannot be submitted due to being close to ``MealDB``.

# License
MIT License, go read it