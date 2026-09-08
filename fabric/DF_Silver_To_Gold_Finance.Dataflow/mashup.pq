[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_account_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_account = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "silver_chart_of_accounts", ItemKind = "Table"]}[Data],
  #"Duplicated column" = Table.DuplicateColumn(#"Navigation 2", "account_description", "account_description - Copy"),
  #"Renamed columns" = Table.RenameColumns(#"Duplicated column", {{"account_description - Copy", "account_name"}})
in
  #"Renamed columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_department_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_department = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "silver_departments", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_entity_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_entity = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "silver_entities", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_fiscal_period_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_fiscal_period = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "silver_fiscal_calendar", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "fact_gl_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared fact_gl = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "silver_gl_journal_lines", ItemKind = "Table"]}[Data],
  #"Merged queries" = Table.NestedJoin(#"Navigation 2", {"entity_code"}, dim_entity, {"entity_code"}, "dim_entity", JoinKind.LeftOuter),
  #"Expanded dim_entity" = Table.ExpandTableColumn(#"Merged queries", "dim_entity", {"entity_id"}, {"entity_id"}),
  #"Merged queries 1" = Table.NestedJoin(#"Expanded dim_entity", {"account_number"}, dim_account, {"account_number"}, "dim_account", JoinKind.LeftOuter),
  #"Expanded dim_account" = Table.ExpandTableColumn(
    #"Merged queries 1",
    "dim_account",
    {"account_number"},
    {"matched_account_number"}
),
  #"Merged queries 2" = Table.NestedJoin(
    #"Expanded dim_account",
    {"entity_code", "department_code"},
    dim_department,
    {"entity_code", "department_code"},
    "dim_department",
    JoinKind.LeftOuter
),
  #"Expanded dim_department" = Table.ExpandTableColumn(#"Merged queries 2", "dim_department", {"department_id"}, {"department_id"}),
  #"Merged queries 3" = Table.NestedJoin(
    #"Expanded dim_department",
    {"entity_code", "location_code"},
    dim_location,
    {"entity_code", "location_code"},
    "dim_location",
    JoinKind.LeftOuter
),
  #"Expanded dim_location" = Table.ExpandTableColumn(#"Merged queries 3", "dim_location", {"location_id"}, {"location_id"}),
  #"Merged queries 4" = Table.NestedJoin(#"Expanded dim_location", {"fiscal_year", "fiscal_period"}, dim_fiscal_period, {"fiscal_year", "fiscal_period"}, "dim_fiscal_period", JoinKind.LeftOuter),
  #"Expanded dim_fiscal_period" = Table.ExpandTableColumn(#"Merged queries 4", "dim_fiscal_period", {"fiscal_period_id"}, {"fiscal_period_id"}),
  #"Added custom" = Table.AddColumn(#"Expanded dim_fiscal_period", "fact_key_status", each if [entity_id] = null then "MISSING_ENTITY" else if [matched_account_number] = null then "MISSING_ACCOUNT" else if [department_id] = null then "MISSING_DEPARTMENT" else if [location_id] = null then "MISSING_LOCATION" else if [fiscal_period_id] = null then "MISSING_FISCAL_PERIOD" else "VALID"),
  #"Added custom 1" = Table.TransformColumnTypes(Table.AddColumn(#"Added custom", "signed_amount", each [debit_amount] - [credit_amount]), {{"signed_amount", type number}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Added custom 1", {{"fact_key_status", type text}, {"fiscal_year", Int64.Type}, {"fiscal_period", Int64.Type}})
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_location_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dim_location = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "silver_locations", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
shared dim_entity_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4858aad8-b808-4872-b47a-e65d47bb875b"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_entity", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared dim_account_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4858aad8-b808-4872-b47a-e65d47bb875b"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_account", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared dim_department_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4858aad8-b808-4872-b47a-e65d47bb875b"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_department", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared dim_location_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4858aad8-b808-4872-b47a-e65d47bb875b"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_location", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared dim_fiscal_period_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4858aad8-b808-4872-b47a-e65d47bb875b"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_fiscal_period", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared fact_gl_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "4858aad8-b808-4872-b47a-e65d47bb875b"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "fact_gl", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
