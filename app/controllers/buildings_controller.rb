class BuildingsController < ApplicationController
  def index
    # TODO Paginate buildings, decide order
    @buildings = Building.all
  end

  def upload_csv
  end

  def create
    # TODO Create a confirmation screen with preview of first ~10 records before creation, using @building_csv_file
    if params[:csv_file].present?
      unless csv_file?(params[:csv_file])
        redirect_to upload_csv_buildings_path, alert: 'Please upload a valid CSV file.', status: :see_other
        return
      end

      @building_csv_file = BuildingCsvFile.new
      @building_csv_file.file.attach(params[:csv_file])

      if @building_csv_file.save
        BuildingCsvImportJob.perform_later(@building_csv_file.id)
        redirect_to buildings_path, notice: 'CSV file uploaded successfully. Processing in background.', status: :see_other
      else
        redirect_to upload_csv_buildings_path, alert: 'Failed to save file.', status: :see_other
      end
    else
      redirect_to upload_csv_buildings_path, alert: 'Please select a CSV file.', status: :see_other
    end
  end

  private

  def csv_file?(file)
    file.original_filename&.downcase&.end_with?('.csv') && file.content_type == 'text/csv'
  end
end
