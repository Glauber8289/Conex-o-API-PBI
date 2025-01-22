// Consulta1
let
    #"Requisição" =
        (numeroPagina) =>
        Json.Document(
            Web.Contents("http://localhost:8080",
            [
                RelativePath = "/medicos",
                Query = [
                    page = Text.From(numeroPagina) // Converte para string
                ]
            ])
        ),

    #"Total Paginas" = #"Requisição"(1)[totalPages],

    #"Lista Dados" = List.Generate(
        ()=> [ Pagina = 0, Consulta = try #"Requisição"(0)[content] otherwise null],
        each [Pagina] < #"Total Paginas",
        each [Consulta = #"Requisição"([Pagina]+1)[content], Pagina = [Pagina]+1],
        each [Consulta]
    ),

    #"Tabela" =
        Table.TransformColumns(
            Table.ExpandRecordColumn(
                Table.ExpandListColumn(
                    Table.FromList(#"Lista Dados", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                    "Column1"
                ),
                "Column1",
                {"id", "nome", "email", "crm", "especialidade"}
            ),
            {
                {"nome", each Text.FromBinary(Text.ToBinary(_, 1252), TextEncoding.Utf8)} // Corrige os caracteres
            }
        )
in
    #"Tabela"