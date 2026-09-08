[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "silver_gl_journal_lines_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared silver_gl_journal_lines = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "fcfe2480-1531-4efd-8d2b-64c380c64621"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "bronze_gl_journal_lines", ItemKind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"debit_amount", type number}, {"credit_amount", type number}})
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "silver_gl_journal_balance_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared silver_gl_journal_balance = let
  Source = silver_gl_journal_lines,
  #"Grouped rows" = Table.Group(Source, {"journal_id"}, {{"total_debit", each List.Sum([debit_amount]), type nullable number}, {"total_credit", each List.Sum([credit_amount]), type nullable number}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Grouped rows", "balance_difference", each [total_debit] - [total_credit]), {{"balance_difference", type number}}),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "journal_balance_status", each if [balance_difference] = 0 then "BALANCED" else "OUT_OF_BALANCE"),
  #"Changed column type" = Table.TransformColumnTypes(#"Added custom 1", {{"journal_balance_status", type text}})
in
  #"Changed column type";
shared silver_gl_journal_lines_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "silver_gl_journal_lines", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared silver_gl_journal_balance_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "silver_gl_journal_balance", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
