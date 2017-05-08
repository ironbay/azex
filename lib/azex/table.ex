defmodule Azex.Table do
	alias Azex.Rest

	def list_tables do
		Rest.exec("Tables")
	end

	def create_table(name) do
		Rest.exec("Tables", "POST", %{TableName: name})
	end

	def get_entities(table) do
		Rest.exec("#{table}()")
	end

	def get_entities(table, partition) do
		Rest.exec("#{table}()?$filter=PartitionKey eq '#{partition}'")
	end

	def insert(table, partition, row, entity) do
		base = %{
			PartitionKey: partition,
			RowKey: row,
		}
		Rest.exec(table, "POST", Map.merge(base, entity))
	end

	def insert_replace(table, partition, row, entity) do
		Rest.exec("#{table}(PartitionKey='#{partition}', RowKey='#{row}')", "PUT", entity)
	end

	def insert_merge(table, partition, row, entity) do
		Rest.exec("#{table}(PartitionKey='#{partition}', RowKey='#{row}')", "MERGE", entity)
	end
end
