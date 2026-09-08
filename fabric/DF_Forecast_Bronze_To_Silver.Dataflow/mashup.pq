[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "silver_forecast_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared silver_forecast = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "fcfe2480-1531-4efd-8d2b-64c380c64621"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "bronze_forecast", ItemKind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"fiscal_year", Int64.Type}, {"fiscal_period", Int64.Type}, {"forecast_amount", type number}}),
  #"Trimmed text" = Table.TransformColumns(#"Changed column type", {{"entity_code", each Text.Trim(_), type nullable text}}),
  #"Cleaned text" = Table.TransformColumns(#"Trimmed text", {{"entity_code", each Text.Clean(_), type nullable text}}),
  #"Trimmed text 1" = Table.TransformColumns(#"Cleaned text", {{"account_number", each Text.Trim(_), type nullable text}}),
  #"Cleaned text 1" = Table.TransformColumns(#"Trimmed text 1", {{"account_number", each Text.Clean(_), type nullable text}}),
  #"Trimmed text 2" = Table.TransformColumns(#"Cleaned text 1", {{"department_code", each Text.Trim(_), type nullable text}}),
  #"Cleaned text 2" = Table.TransformColumns(#"Trimmed text 2", {{"department_code", each Text.Clean(_), type nullable text}}),
  #"Removed columns" = Table.RemoveColumns(#"Cleaned text 2", {"Prop_7"}, MissingField.Ignore),
  #"Merged queries" = Table.NestedJoin(#"Removed columns", {"entity_code"}, silver_entities, {"entity_code"}, "silver_entities", JoinKind.LeftOuter),
  #"Expanded silver_entities" = Table.ExpandTableColumn(#"Merged queries", "silver_entities", {"entity_code"}, {"entity_code.1"}),
  #"Renamed columns" = Table.RenameColumns(#"Expanded silver_entities", {{"entity_code.1", "matched_entity_code"}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Renamed columns", "entity_validation_status", each if [matched_entity_code] = null then "INVALID_ENTITY" else "VALID"), {{"entity_validation_status", type text}}),
  #"Merged queries 1" = Table.NestedJoin(#"Added custom", {"account_number"}, silver_chart_of_accounts, {"account_number"}, "silver_chart_of_accounts", JoinKind.LeftOuter),
  #"Expanded silver_chart_of_accounts" = Table.ExpandTableColumn(#"Merged queries 1", "silver_chart_of_accounts", {"account_number"}, {"account_number.1"}),
  #"Renamed columns 1" = Table.RenameColumns(#"Expanded silver_chart_of_accounts", {{"account_number.1", "matched_account_number"}}),
  #"Added custom 1" = Table.TransformColumnTypes(Table.AddColumn(#"Renamed columns 1", "account_validation_status", each if [matched_account_number] = null then "INVALID_ACCOUNT" else "VALID"), {{"account_validation_status", type text}}),
  #"Merged queries 2" = Table.NestedJoin(#"Added custom 1", {"department_code"}, silver_departments, {"department_code"}, "silver_departments", JoinKind.LeftOuter),
  #"Expanded silver_departments" = Table.ExpandTableColumn(#"Merged queries 2", "silver_departments", {"department_code"}, {"department_code.1"}),
  #"Renamed columns 2" = Table.RenameColumns(#"Expanded silver_departments", {{"department_code.1", "matched_department_code"}}),
  #"Added custom 2" = Table.TransformColumnTypes(Table.AddColumn(#"Renamed columns 2", "department_validation_status", each if [matched_department_code] = null then "INVALID_DEPARTMENT" else "VALID"), {{"department_validation_status", type text}}),
  #"Merged queries 3" = Table.NestedJoin(#"Added custom 2", {"fiscal_year", "fiscal_period"}, silver_fiscal_calendar, {"fiscal_year", "fiscal_period"}, "silver_fiscal_calendar", JoinKind.LeftOuter),
  #"Expanded silver_fiscal_calendar" = Table.ExpandTableColumn(#"Merged queries 3", "silver_fiscal_calendar", {"fiscal_period_id"}, {"fiscal_period_id"}),
  #"Added custom 3" = Table.TransformColumnTypes(Table.AddColumn(#"Expanded silver_fiscal_calendar", "forecast_validation_status", each if [entity_validation_status] <> "VALID" then "INVALID_REFERENCE"
else if [account_validation_status] <> "VALID" then "INVALID_REFERENCE"
else if [department_validation_status] <> "VALID" then "INVALID_REFERENCE"
else if [fiscal_period_id] = null then "INVALID_FISCAL_PERIOD"
else "VALID"), {{"forecast_validation_status", type text}}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Added custom 3", {{"account_number", Int64.Type}, {"matched_account_number", Int64.Type}})
in
  #"Changed column type 1";
shared silver_chart_of_accounts = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "silver_chart_of_accounts", ItemKind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"account_number", Int64.Type}})
in
  #"Changed column type";
shared silver_departments = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "silver_departments", ItemKind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"department_id", Int64.Type}})
in
  #"Changed column type";
shared silver_entities = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "silver_entities", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
shared silver_fiscal_calendar = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "silver_fiscal_calendar", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
shared silver_forecast_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "silver_forecast", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
