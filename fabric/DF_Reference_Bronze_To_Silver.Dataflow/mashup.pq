[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "silver_chart_of_accounts_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared silver_chart_of_accounts = let
  Source = Lakehouse.Contents(null),
  #"Navigation 1" = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseId = "fcfe2480-1531-4efd-8d2b-64c380c64621"]}[Data],
  Navigation = #"Navigation 2"{[Id = "bronze_chart_of_accounts", ItemKind = "Table"]}[Data]
in
  Navigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "silver_departments_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared silver_departments = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "fcfe2480-1531-4efd-8d2b-64c380c64621"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "bronze_departments", ItemKind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"department_id", Int64.Type}, {"department_code", type text}, {"is_active", type logical}}),
  #"Trimmed text" = Table.TransformColumns(#"Changed column type", {{"department_code", each Text.Trim(_), type nullable text}}),
  #"Cleaned text" = Table.TransformColumns(#"Trimmed text", {{"department_code", each Text.Clean(_), type nullable text}}),
  #"Trimmed text 1" = Table.TransformColumns(#"Cleaned text", {{"entity_code", each Text.Trim(_), type nullable text}}),
  #"Cleaned text 1" = Table.TransformColumns(#"Trimmed text 1", {{"entity_code", each Text.Clean(_), type nullable text}}),
  #"Removed duplicates" = Table.Distinct(#"Cleaned text 1", {"department_code"})
in
  #"Removed duplicates";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "silver_entities_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared silver_entities = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "fcfe2480-1531-4efd-8d2b-64c380c64621"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "bronze_entities", ItemKind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 2", {{"entity_id", Int64.Type}, {"entity_code", type text}, {"is_active", type logical}}),
  #"Trimmed text" = Table.TransformColumns(#"Changed column type", {{"entity_code", each Text.Trim(_), type nullable text}}),
  #"Cleaned text" = Table.TransformColumns(#"Trimmed text", {{"entity_code", each Text.Clean(_), type nullable text}}),
  #"Trimmed text 1" = Table.TransformColumns(#"Cleaned text", {{"base_currency", each Text.Trim(_), type nullable text}}),
  #"Uppercased text" = Table.TransformColumns(#"Trimmed text 1", {{"base_currency", each Text.Upper(_), type nullable text}}),
  #"Removed duplicates" = Table.Distinct(#"Uppercased text", {"entity_code"})
in
  #"Removed duplicates";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "silver_fiscal_calendar_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared silver_fiscal_calendar = let
  Source = Lakehouse.Contents(null),
  #"Navigation 1" = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseId = "fcfe2480-1531-4efd-8d2b-64c380c64621"]}[Data],
  Navigation = #"Navigation 2"{[Id = "bronze_fiscal_calendar", ItemKind = "Table"]}[Data]
in
  Navigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "silver_locations_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared silver_locations = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "fcfe2480-1531-4efd-8d2b-64c380c64621"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "bronze_locations", ItemKind = "Table"]}[Data],
  #"Trimmed text" = Table.TransformColumns(#"Navigation 2", {{"location_code", each Text.Trim(_), type nullable text}}),
  #"Cleaned text" = Table.TransformColumns(#"Trimmed text", {{"location_code", each Text.Clean(_), type nullable text}}),
  #"Trimmed text 1" = Table.TransformColumns(#"Cleaned text", {{"entity_code", each Text.Trim(_), type nullable text}}),
  #"Cleaned text 1" = Table.TransformColumns(#"Trimmed text 1", {{"entity_code", each Text.Clean(_), type nullable text}}),
  #"Removed duplicates" = Table.Distinct(#"Cleaned text 1", {"location_code"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed duplicates", {{"location_id", Int64.Type}, {"is_active", type logical}})
in
  #"Changed column type";
shared silver_entities_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "silver_entities", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared silver_chart_of_accounts_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "silver_chart_of_accounts", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared silver_departments_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "silver_departments", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared silver_locations_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "silver_locations", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared silver_fiscal_calendar_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "silver_fiscal_calendar", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "silver_gl_reference_validation_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared silver_gl_reference_validation = let
  Source = Lakehouse.Contents(null),
  #"Navigation 1" = Source{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  Navigation = #"Navigation 2"{[Id = "silver_gl_reference_validation", ItemKind = "Table"]}[Data]
in
  Navigation;
shared silver_gl_reference_validation_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "31c4a11c-aa0b-4a06-a995-be57fe20be3f"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "2efeecaf-5f97-45c4-82af-2d62bcbfc231"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "silver_gl_reference_validation", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
