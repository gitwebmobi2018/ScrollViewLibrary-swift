import UIKit

final class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var undoBarButtonItem: UIBarButtonItem!
    @IBOutlet var trashBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var horizontalScrollerView: HorizontalScrollerView!
    
    private var currentAlbumIndex = 0
    private var currentAlbumData: [AlbumData]?
    private var allAlbums = [Album]()
  
  static let IndexRestorationKey = "currentAlbumIndex"
  
    override func viewDidLoad() {
        super.viewDidLoad()
        allAlbums = LibraryAPI.shared.getAlbums()
    
        showDataForAlbum(at: currentAlbumIndex)
      
      horizontalScrollerView.dataSource = self
      horizontalScrollerView.delegate = self
      horizontalScrollerView.reload()
    }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    horizontalScrollerView.scrollToView(at: currentAlbumIndex, animated: false)
  }
  
  override func encodeRestorableState(with coder: NSCoder) {
    coder.encode(currentAlbumIndex, forKey: ViewController.IndexRestorationKey)
    super.encodeRestorableState(with: coder)
  }
  
  override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)
    currentAlbumIndex = coder.decodeInteger(forKey: ViewController.IndexRestorationKey)
    showDataForAlbum(at: currentAlbumIndex)
    horizontalScrollerView.reload()
  }
  
    private func showDataForAlbum(at index: Int) {
        if (index < allAlbums.count && index > -1) {
            let album = allAlbums[index]
            currentAlbumData = album.tableRepresentation
        } else {
            currentAlbumData = nil
        }
        tableView.reloadData()
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let albumData = currentAlbumData else {
            return 0
        }
        return albumData.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let albumData = currentAlbumData {
            let row = indexPath.row
            cell.textLabel!.text = albumData[row].title
            cell.detailTextLabel!.text = albumData[row].value
        }
        return cell
    }
  
}

extension ViewController: HorizontalScrollerViewDelegate {
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int) {

        let previousAlbumView = horizontalScrollerView.view(at: currentAlbumIndex) as! AlbumView
        previousAlbumView.highlightAlbum(false)

        currentAlbumIndex = index

        let albumView = horizontalScrollerView.view(at: currentAlbumIndex) as! AlbumView
        albumView.highlightAlbum(true)

        showDataForAlbum(at: index)
    }
}

extension ViewController: HorizontalScrollerViewDataSource {
  func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int {
    return allAlbums.count
  }
  
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView {
    let album = allAlbums[index]
    let albumView = AlbumView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), coverUrl: album.coverUrl)
    if currentAlbumIndex == index {
      albumView.highlightAlbum(true)
    } else {
      albumView.highlightAlbum(false)
    }
    return albumView
  }
}
