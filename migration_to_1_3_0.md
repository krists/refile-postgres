# Migration to refile-postgres version 1.3.0

Please check [issue](https://github.com/krists/refile-postgres/issues/9) for more details.

1) Change Rails schema dump format to SQL in your `config/application.rb` file
   ```ruby
   # Use structure.sql instead of schema.rb
   config.active_record.schema_format = :sql
   ```
2) Change version number in Gemfile
   ```ruby
   gem 'refile-postgres', '~> 1.3.0'
   ```
3) Create Rails migration
   ```
   rails g migration refile_postgres_migration_to_1_3_0
   ```
4) Add content to migration
   ```ruby
   class RefilePostgresMigrationTo130 < ActiveRecord::Migration
     def up
       execute <<-SQL
         DROP INDEX index_refile_attachments_on_namespace;
         ALTER TABLE refile_attachments RENAME TO old_refile_attachments;
         ALTER TABLE ONLY old_refile_attachments RENAME CONSTRAINT refile_attachments_pkey TO old_refile_attachments_pkey;
         CREATE TABLE refile_attachments (
           id integer NOT NULL,
           oid oid NOT NULL,
           namespace character varying NOT NULL,
           created_at timestamp without time zone DEFAULT ('now'::text)::timestamp without time zone
         );
         ALTER TABLE ONLY refile_attachments ADD CONSTRAINT refile_attachments_pkey PRIMARY KEY (id);
         ALTER SEQUENCE refile_attachments_id_seq RESTART OWNED BY refile_attachments.id;
         ALTER TABLE ONLY refile_attachments ALTER COLUMN id SET DEFAULT nextval('refile_attachments_id_seq'::regclass);
         INSERT INTO refile_attachments (oid, namespace) SELECT id, namespace FROM old_refile_attachments;
         CREATE INDEX index_refile_attachments_on_namespace ON refile_attachments USING btree (namespace);
         CREATE INDEX index_refile_attachments_on_oid ON refile_attachments USING btree (oid);
         DROP TABLE old_refile_attachments;
       SQL
     end

     def down
       raise ActiveRecord::IrreversibleMigration
     end
   end
   ```
5) Now it is safe to run [vacuumlo](http://www.postgresql.org/docs/9.5/static/vacuumlo.html)
