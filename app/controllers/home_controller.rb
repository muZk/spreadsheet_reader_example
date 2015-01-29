class HomeController < ApplicationController
  def index
    if request.post?
      @rows = UserSpreadsheet.read_spreadsheet(params[:file].path)
      @row = @rows.invalid_row
      puts @row
    end
  end
end
