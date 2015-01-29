class UserSpreadsheet < RailsSpreadsheetReader::Base

  # add the columns you want to read:
  attr_accessor :username, :email

  # add validations to your fields
  validates_presence_of :username, :email

  # map this model attributes to your spreadsheet attributes
  # you can use a hash { attr1: 0, attr2: 1, attr3: 2, ... }
  # or a array %w(attr1 attr2 attr3 ...)

  def self.columns
    %w(username email)
  end

  # set the row number where the data start, default is 2 (1-based)
  def self.starting_row
    2
  end

  def self.validate_multiple_rows(row_collection)
    # Validate the uniqueness of username in the row_collection set
    username_list = []
    row_collection.rows.each do |row|
      if username_list.include?(row.username)
        row_collection.invalid_row = row
        row.errors[:username] = 'is unique'
        raise 'Validation Error'
      else
        username_list << row.username
      end
    end
  end

  def self.persist(row_collection)
    User.transaction do
      row_collection.rows.each do |row|
        user = User.new(username: row.username, email: row.email)
        unless user.save
          row_collection.set_invalid_row(row, user) # pass the model with errors as second parameter
          rollback # use the rollback helper to rollback the transaction.
        end
      end
    end
  end

end