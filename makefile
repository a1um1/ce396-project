generate-sql:
	@echo "Generating SQL files..."
	dbml2sql schema.dbml --postgres -o schema.sql