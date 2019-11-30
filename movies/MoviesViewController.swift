//
//  ViewController.swift
//  movies
//
//  Created by Vides, Rigoberto on 11/29/19.
//  Copyright © 2019 Rigo Vides. All rights reserved.
//

import UIKit

typealias JSON = [String : Any]

struct Movie {
    let title: String //trackName
    let movieDescription: String //longDescription
    let image: UIImage? = nil

    private var imageURL = URL(string: "some://path/to/defaultImage.jpg")! //artworkUrl100

    public init(json: JSON) {
        self.title = (json["trackName"] as? String) ?? ""
        self.movieDescription = (json["longDescription"] as? String) ?? ""

        if let path = json["artworkUrl100"] as? String, let url = URL(string: path) {
            self.imageURL = url
        }
    }
}

class MoviesViewController: UITableViewController {
    var movies = [Movie]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        guard let moviesURL = URL(string: "https://itunes.apple.com/search?term=horror&media=movie") else {
            return
        }

        //fetch
        URLSession.shared.dataTask(with: moviesURL) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300,
                let data = data,
                error == nil else {
                    return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSON else { return }

            guard let results = json["results"] as? [JSON] else { return }

            results.forEach { json in
                self.movies.append(Movie(json: json))
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.resume()
        //populate
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "movies-cell", for: indexPath)
        let movie = self.movies[indexPath.row]
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = movie.movieDescription
        return cell
    }
}

