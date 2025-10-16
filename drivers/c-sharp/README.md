# C# README

This project builds the Speedo driver for SaxonCS. Place the version of SaxonCS
that you want to build against in the `SaxonCS` directory. 

NOTE: The Speedo project package references and the SaxonCS package references
must be the same. In particular, note that the versions may differ if you switch
between SaxonCS versions!

The commands:

```
dotnet restore Speedo.sln
dotnet build Speedo.sln
dotnet publish Speedo.sln
```

should succeed and place a runnable version of Speedo in
`bin/Release/net8.0/publish/Speedo`
