#DB[:conn]
require 'pry'
class Dog
  attr_accessor :id, :name, :breed

  # ATTRIBUTES = {
  # 	id: "INTEGER PRIMARY KEY AUTOINCREMENT",
  # 	name: "TEXT",
  # 	breed: "TEXT"
  # }

  # def self.public_attributes	# name, breed
  # 	ATTRIBUTES.keys.reject { |key| key == :id }
  # end

  # def values 	#send name & breed, get return values
  # 	self.class.public_attributes.map { |attr| self.send(attr) }
  # 	# => grab all the public attributes
  # 	# send each one to Dog instance
  # 	# collect return values
  # 	# use this info to update Dog instance's row in database
  # end

  # def attributes
  # 	self.class.public_attributes.map {|attr| "#{attr} = ?" }.join(', ')
  # 	# => name = ?, breed = ?
  # 	# used for UPDATE method below to automagically
  # 	# insert a Dog's attributes into the SQL code
  # end

  #accepts hash/keyword argument with key-value pairs
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.table
    "#{self.to_s.downcase}s"
    #Dog = dogs
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS #{self.table} (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE #{self.table};"
    DB[:conn].execute(sql)
  end

  # row = [id, name, breed]
  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    #look for row in DB with same name
    sql = "SELECT * FROM #{self.table} WHERE name = ?;"
    row = DB[:conn].execute(sql, name)[0]
    #create dog object from db
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def update
    sql = "UPDATE #{self.class.table} SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def persisted?
    !!self.id
  end

  def save
    sql = "INSERT INTO #{self.class.table} (name, breed) VALUES (?, ?);"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    # did not pass id because the dog isn't saved in the db
    dog = self.new(name: attributes[:name], breed: attributes[:breed])
    dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    row = DB[:conn].execute(sql, id)[0]
    dog = self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(attributes)
    name = attributes[:name]
    breed = attributes[:breed]

    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    row = DB[:conn].execute(sql, name, breed)[0]

    if row.nil?   
      # if dog doesn't exist in db create new one (and save)
      new_dog = self.create(name: name, breed: breed)
    else
      #creates new instance of existing dog in DB to return
      dog = self.new(id: row[0], name: row[1], breed: row[2])
    end
  end

end

#Pry.start

