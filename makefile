all: check generate-sql format

check:
	@echo "> Checking for require dependencies..."
	@which dbml2sql > /dev/null 2>&1 || (echo "Required dependency 'dbml2sql' is not installed.\nnpm install -g @dbml/cli" && exit 1)

generate-sql:
	@echo "> Generating SQL files..."
	dbml2sql schema.dbml --postgres -o schema.sql

format:
	@echo "> Formatting generated files..."

	@echo "  - Removing DEFERRABLE INITIALLY IMMEDIATE..."
	@sed -i '' 's/ DEFERRABLE INITIALLY IMMEDIATE//g' schema.sql

	@echo "  - Formatting constraints..."
	@sed -i '' -E 's/ (ADD CONSTRAINT|FOREIGN KEY|REFERENCES|ON DELETE|ON UPDATE)/\n\t\1/g' schema.sql
	