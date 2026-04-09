require "mini_magick"

class ProfessorPhotoService
  PHOTO_DIR = Rails.root.join("public", "photos", "professors")
  SIZE = 300

  def self.process_upload(professor, uploaded_file)
    return { error: "No file" } if uploaded_file.blank?

    FileUtils.mkdir_p(PHOTO_DIR)

    filename = "prof_#{professor.id}.jpg"
    output_path = PHOTO_DIR.join(filename)

    image = MiniMagick::Image.read(uploaded_file.read)
    uploaded_file.rewind

    image.combine_options do |c|
      c.resize "#{SIZE}x#{SIZE}^"
      c.gravity "center"
      c.extent "#{SIZE}x#{SIZE}"
      c.quality 85
    end
    image.format "jpg"
    image.write(output_path)

    "/photos/professors/#{filename}"
  rescue => e
    { error: e.message }
  end

  def self.delete_photos(professor)
    path = PHOTO_DIR.join("prof_#{professor.id}.jpg")
    FileUtils.rm_f(path)
  end

  def self.download_from_url(professor, url)
    return { error: "No URL" } if url.blank?

    require "open-uri"
    tempfile = URI.parse(url).open
    uploaded = ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: "download.jpg",
      type: "image/jpeg"
    )
    process_upload(professor, uploaded)
  rescue => e
    { error: e.message }
  end
end
