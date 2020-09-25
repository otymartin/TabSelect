//
//  ContentView.swift
//  TabSelect
//
//  Created by Martin Otyeka on 2020-09-25.
//

import SwiftUI

import SwiftUI

protocol TabSelectable {
	associatedtype Tab
	func shouldSelect(_ tab: Tab) -> Bool
}

@propertyWrapper
struct TabSelection<Value: Hashable> {
	
	init(wrappedValue: Value) {
		_selection = wrappedValue
	}
	
	var _selection: Value
	private var selectable: ((Value) -> Bool)?
	
	mutating func register<S>(_ selectable: S) where S : TabSelectable, Value == S.Tab {
		self.selectable = selectable.shouldSelect
	}
	
	var wrappedValue: Value {
		get { _selection }
		set {
			guard selectable?(newValue) ?? true else {
				return
			}
			
			_selection = newValue
		}
	}
}

enum TabName: Hashable {
	case home
	case news
	case more
}

class TabSelect: ObservableObject, TabSelectable {
	
	init() {
		_selection.register(self)
	}

	func shouldSelect(_ tab: TabName) -> Bool {
		guard tab != .more else {
			showModal.toggle()
			return false
		}
		
		return true
	}
		
	@TabSelection var selection = Tab.home {
		willSet {
			objectWillChange.send()
		}
	}
	
	var showModal = false
}

struct ContentView: View {
	
	@StateObject var tabSelect = TabSelect()
	
	var body: some View {
		TabView(selection: $tabSelect.selection) {
			TabItemView(title: "Home")
				.tabItem {
					Text("Home")
				}
				.tag(TabName.home)
			
			TabItemView(title: "News")
				.tabItem {
					Text("News")
				}
				.tag(TabName.news)
			
			TabItemView(title: "More")
				.tabItem {
					Text("More")
				}
				.tag(TabName.more)
		}
		.sheet(isPresented: $tabSelect.showModal) {
			Text("Modal")
		}
	}
}

struct TabItemView: View {
	
	let title: String
	
	var body: some View {
		NavigationView {
			Text("")
				.navigationBarTitle(Text(title), displayMode: .large)
		}
	}
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
