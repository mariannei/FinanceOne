[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "fact_budget_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared fact_budget = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "silver_budget", ItemKind = "Table"]}[Data],
  #"Merged queries" = Table.NestedJoin(#"Navigation 2", {"entity_code"}, dim_entity, {"entity_code"}, "dim_entity", JoinKind.LeftOuter),
  #"Expanded dim_entity" = Table.ExpandTableColumn(#"Merged queries", "dim_entity", {"entity_id"}, {"entity_id"}),
  #"Merged queries 1" = Table.NestedJoin(
    Table.TransformColumnTypes(#"Expanded dim_entity", {{"account_number", type text}}),
    {"account_number"},
    Table.TransformColumnTypes(dim_account, {{"account_number", type text}}),
    {"account_number"},
    "dim_account",
    JoinKind.LeftOuter
),
  #"Changed column type 2" = Table.TransformColumnTypes(#"Merged queries 1", {{"account_number", Int64.Type}}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Changed column type 2", {{"account_number", Int64.Type}}),
  #"Expanded dim_account" = Table.ExpandTableColumn(
    #"Changed column type 1",
    "dim_account",
    {"account_number"},
    {"matched_budget_account_number"}
),
  #"Merged queries 2" = Table.NestedJoin(#"Expanded dim_account", {"department_code"}, dim_department, {"department_code"}, "dim_department", JoinKind.LeftOuter),
  #"Expanded dim_department" = Table.ExpandTableColumn(#"Merged queries 2", "dim_department", {"department_id"}, {"department_id"}),
  #"Merged queries 3" = Table.NestedJoin(#"Expanded dim_department", {"fiscal_year", "fiscal_period"}, dim_fiscal_period, {"fiscal_year", "fiscal_period"}, "dim_fiscal_period", JoinKind.LeftOuter),
  #"Expanded dim_fiscal_period" = Table.ExpandTableColumn(#"Merged queries 3", "dim_fiscal_period", {"fiscal_period_id"}, {"fiscal_period_id.1"}),
  #"Renamed columns" = Table.RenameColumns(#"Expanded dim_fiscal_period", {{"fiscal_period_id.1", "matched_fiscal_period_id"}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Renamed columns", "fact_budget_key_status", each if [entity_id] = null then "MISSING_ENTITY"
else if [matched_budget_account_number] = null then "MISSING_ACCOUNT"
else if [department_id] = null then "MISSING_DEPARTMENT"
else if [matched_fiscal_period_id] = null then "MISSING_FISCAL_PERIOD"
else "VALID"), {{"fact_budget_key_status", type text}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Added custom", {{"account_number", type text}, {"matched_account_number", type text}, {"entity_code", type text}, {"matched_entity_code", type text}})
in
  #"Changed column type";
shared dim_account = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4858aad8-b808-4872-b47a-e65d47bb875b"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "dim_account", ItemKind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"account_number", type text}})
in
  #"Changed column type";
shared dim_department = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4858aad8-b808-4872-b47a-e65d47bb875b"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "dim_department", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
shared dim_entity = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4858aad8-b808-4872-b47a-e65d47bb875b"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "dim_entity", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
shared dim_fiscal_period = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4858aad8-b808-4872-b47a-e65d47bb875b"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "dim_fiscal_period", ItemKind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"fiscal_year", Int64.Type}, {"fiscal_period", Int64.Type}})
in
  #"Changed column type";
shared fact_budget_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4858aad8-b808-4872-b47a-e65d47bb875b"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "fact_budget", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
