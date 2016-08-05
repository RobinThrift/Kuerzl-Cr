require "uri"
require "db"
require "sqlite3"
require "kemal"

DB.open "sqlite3:./shortcry.db" do |db|
    db.exec "CREATE TABLE IF NOT EXISTS links (id INTEGER PRIMARY KEY, date_created INTEGER, url TEXT)"
end

get "/" do
    "Hello World!"
end


get "/links" do
    links = [] of {id: Int32, date_created: Int32, link: String}
    DB.open "sqlite3:./shortcry.db" do |db|
        db.query "SELECT * FROM links" do |row|
            row.each do
                links.push({id: row.read(Int32), date_created: row.read(Int32), link: row.read(String)})
            end
        end
    end

    links.to_json
end

post "/links" do |env|
    link = env.params.json["link"] as String
    puts "insertig '#{link}' into db"

    uri = URI.parse link


    if uri.host.nil? && uri.path.nil? && uri.scheme.nil?
        env.response.status_code = 401
    else
        now = Time.now.to_s("%s")

        DB.open "sqlite3:./shortcry.db" do |db|
            db.exec "INSERT INTO links (date_created, url) VALUES (?, ?)", now, link
        end

        env.response.status_code = 201
    end
end

Kemal.run
