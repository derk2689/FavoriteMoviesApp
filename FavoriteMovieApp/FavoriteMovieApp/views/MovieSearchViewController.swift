//
//  MovieSearchViewController.swift
//  FavoriteMovieApp
//
//  Created by Derek Clevenger on 6/11/18.
//  Copyright © 2018 Derek Clevenger. All rights reserved.
//

import UIKit

class MovieSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: FavoriteMoviesViewController!
    var searchResults: [Movie] = []
    var movieSearchTableView = UITableView()
    
    var searchTextField = UITextField()
    var searchButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupSearchTextField()
        setupSearchButton()
        setupMovieSearchTableView()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSearchTextField()
        layoutSearchButton()
        layoutMovieSearchTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    func setupSearchTextField() {
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.backgroundColor = UIColor.clear
        searchTextField.borderStyle = .roundedRect
        searchTextField.textAlignment = .left
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
    
        view.addSubview(searchTextField)

    }
    
    func layoutSearchTextField() {
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height * 0.1),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5.0),
            searchTextField.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.08),
            searchTextField.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7)
            ])
    }
    
    func setupSearchButton() {
        searchButton.setTitle("Search", for: UIControlState())
        searchButton.backgroundColor = UIColor.lightGray
        searchButton.layer.borderColor = UIColor.white.cgColor
        searchButton.layer.borderWidth = 1
        
        searchButton.setTitleColor(.white, for: UIControlState())
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchButton)
    }
    
    func layoutSearchButton() {
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height * 0.1),
            searchButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 5.0),
            searchButton.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.08),
            searchButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.25)
            ])
    }
    

    
    func setupMovieSearchTableView() {
        movieSearchTableView.dataSource = self

        movieSearchTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "customcell")
        movieSearchTableView.translatesAutoresizingMaskIntoConstraints = false
        movieSearchTableView.rowHeight = 100.0
        view.addSubview(movieSearchTableView)
    }
    
    func layoutMovieSearchTableView() {
        NSLayoutConstraint.activate([
            movieSearchTableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 5.0),
           movieSearchTableView.leftAnchor.constraint(equalTo:view.leftAnchor),
           movieSearchTableView.rightAnchor.constraint(equalTo:view.rightAnchor),
            movieSearchTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    @objc func search(sender: UIButton) {
        print("Searching for \(self.searchTextField.text!)")
        
        let searchTerm = searchTextField.text!
        if searchTerm.count > 2 {
            retrieveMoviesByTerm(searchTerm: searchTerm)
        }
    }
    
    @objc func addFav (sender: UIButton) {
        print("Item #\(sender.tag) was selected as a favorite")
        self.delegate.favoriteMovies.append(searchResults[sender.tag])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200.0
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        // at init/appear ... this runs for each visible cell that needs to render
//
        let moviecell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as! CustomTableViewCell

        let idx: Int = indexPath.row
        moviecell.favButton.tag = idx
        //title
        moviecell.movieTitle.text = searchResults[idx].title
        //year
        moviecell.movieYear.text = searchResults[idx].year
        
        moviecell.favButton.addTarget(self, action: #selector(addFav), for: .touchUpInside)

        // image
        displayMovieImage(idx, movieCell: moviecell)

        return moviecell

    }


   
    func displayMovieImage(_ row: Int, movieCell: CustomTableViewCell) {
        let url: String = (URL(string: searchResults[row].imageUrl)?.absoluteString)!
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                movieCell.movieImage.image = image
            })
        }).resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveMoviesByTerm(searchTerm: String) {
        let url = "https://www.omdbapi.com/?i=tt3896198&apikey=9b0cb7f4&s=\(searchTerm)&type=movie&r=json"
        HTTPHandler.getJson(urlString: url, completionHandler: parseDataIntoMovies)
    }
    
    func parseDataIntoMovies(data: Data?) -> Void {
        if let data = data {
            let object = JSONParser.parse(data: data)
            if let object = object {
                self.searchResults = MovieDataProcessing.mapJsonToMovies(object: object, moviesKey: "Search")
                DispatchQueue.main.async {
                    self.movieSearchTableView.reloadData()
                }
            }
        }
    }
}


/*
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


