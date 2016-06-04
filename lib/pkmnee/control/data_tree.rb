require_relative 'data_tree_item'

module PKMNEE::Control

	class DataTreeView < JavaFX::TreeTableView

		def initialize(data)
			super()
			setMinHeight(self.class::USE_PREF_SIZE)
			setMaxHeight(Java::Double::MAX_VALUE)
			setPrefHeight(900)
			@data = data
			@col1 = JavaFX::TreeTableColumn.new("Name")
			@col1.setCellValueFactory(lambda do |e| 
				JavaFX::ReadOnlyStringWrapper.new(e.getValue.getValue[0]) 
			end )
			@col1.setPrefWidth(200)
			@col2 = JavaFX::TreeTableColumn.new("Value")
			@col2.setCellValueFactory(lambda do |e| 
				JavaFX::ReadOnlyStringWrapper.new(e.getValue.getValue[1]) 
			end )
			@col2.setPrefWidth(1200)
			setColumnResizePolicy(JavaFX::TreeTableView::CONSTRAINED_RESIZE_POLICY)
			if @data.is_a?(PKMNEE::Util::DataSet) # collection of data objects
				root = PKMNEE::Control::DataTreeItem.new([@data.to_s, @data.inspect], @data.data)
				root.getChildren
				root.setExpanded(true)
				setRoot(root)
				# recursiveAppendChildren(@data.data, root)
			else # is single data object
				root = PKMNEE::Control::DataTreeItem.new([@data.to_s, @data.id], @data)
				root.setExpanded(true)
				root.getChildren
				setRoot(root)
				# recursiveAppendChildren(@data, root)
			end
			getColumns.addAll(@col1, @col2)
			setShowRoot(true)
		end

		def recursiveAppendChildren(data, parent = nil)
			if data.is_a?(Hash)
				data.each do |k,v|
					item = JavaFX::TreeItem.new( [k.to_s, simpleType(v)] )
					parent.getChildren.add(item)
					recursiveAppendChildren(v, item)
				end
			elsif data.is_a?(Array)
				data.each_index do |i|
					item = JavaFX::TreeItem.new( [i.to_s, simpleType(data[i])] )
					parent.getChildren.add(item)
					recursiveAppendChildren(data[i], item)
				end
			else
				data.instance_variables.each do |e|
					value = data.instance_variable_get(e)
					item = JavaFX::TreeItem.new( [e.to_s, simpleType(value)] )
					parent.getChildren.add(item)
					recursiveAppendChildren(value, item)
				end
			end
		end
	end
end
