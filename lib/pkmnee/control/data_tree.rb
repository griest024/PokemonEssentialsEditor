require_relative 'data_tree_item'

module PKMNEE::Control

	class DataTreeView < JavaFX::TreeTableView

		def initialize(data)
			super()
			setMinHeight(self.class::USE_PREF_SIZE)
			setMaxHeight(Java::Double::MAX_VALUE)
			setPrefHeight(900)
			@data = data
			@name_col = JavaFX::TreeTableColumn.new("Name")
			@name_col.setCellValueFactory(lambda do |e| 
				JavaFX::ReadOnlyStringWrapper.new(e.getValue.getValue[0]) 
			end )
			@name_col.setPrefWidth(200)
			@value_col = JavaFX::TreeTableColumn.new("Value")
			@value_col.setCellValueFactory(lambda do |e| 
				JavaFX::ReadOnlyStringWrapper.new(e.getValue.getValue[1]) 
			end )
			@value_col.setPrefWidth(1200)
			setColumnResizePolicy(JavaFX::TreeTableView::CONSTRAINED_RESIZE_POLICY)
			if @data.is_a?(PKMNEE::Util::DataSet) # collection of data objects
				root = PKMNEE::Control::DataTreeItem.new([@data.to_s, @data.inspect], @data)
				root.getChildren
				root.setExpanded(true)
				setRoot(root)
			else # is single data object
				root = PKMNEE::Control::DataTreeItem.new([@data.to_s, @data.id], @data)
				root.setExpanded(true)
				root.getChildren
				setRoot(root)
			end
			getColumns.addAll(@name_col, @value_col)
			setShowRoot(true)
		end
	end
end
