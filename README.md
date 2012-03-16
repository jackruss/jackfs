# Jackfs

Is a rails 3 file store plugin, that allows you to create a simple file store system
that can point to disk, s3, or database based on your configuration file.

This allows you to implement the storage using a simple api.  The plugin is 
adapter driven, so you can create additional adapters to use for this Jackfs
system.

## Install

    rails plugin install git://github.com/jackhq/jackfs.git
    
## Configure

* If File Adapter your config/filestore.yml would look like this

    production:
      location: tmp
      adapter: file
  
  
* If Db Adapter your config/filestore.yml would look like this

    production:
      connection: sqlite://production.db
      adapter: db
      table_name: jackfs
    
** It is important to note that it uses the sequel toolkit to connect to the database.  The connection setting must be a valid sequel toolkit connection string.

* If S3 Adapter your config/filestore.yml would look like this

    production:
      adapter: s3
      bucket: jackhq
      access_key: ACCESS KEY
      secret_key: SECRET KEY

---

# Report any problems to team@jackrussellsoftware.com
