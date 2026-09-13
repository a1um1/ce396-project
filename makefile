all: generate-sql format

generate-sql:
	@echo "Generating SQL files..."
	dbml2sql schema.dbml --postgres -o schema.sql

format:
	@echo "Cleaning up generated files..."
	sed -i '' 's/ DEFERRABLE INITIALLY IMMEDIATE//g' schema.sql
	sed -i '' -E  's/ (ADD CONSTRAINT|FOREIGN KEY|REFERENCES|ON DELETE|ON UPDATE)/\n\t\1/g' schema.sql