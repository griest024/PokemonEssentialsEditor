
module PKMNEE::Control

	class DataTreeItem < JavaFX::TreeItem

		attr_accessor :is_leaf, :is_first_time_leaf, :is_first_time_child, :data

		def initialize(value, data)
			super(value)
			@data = data
			@is_first_time_child = true
			@is_first_time_leaf = true
			addEventHandler(JavaFX::TreeItem::TreeModificationEvent::ANY, lambda { |event| event.getTarget.getChildren.toArray.each { |e| e.getChildren } if event.wasExpanded })
		end

		def isLeaf?
			if @is_first_time_leaf
				@is_first_time_leaf = false
				@is_leaf = simpleType?(@data)
			end
			@is_leaf
		end

		def getChildren
			if @is_first_time_child
				@is_first_time_child = false
				super.setAll(buildChildren)
			end
			super
		end
		
		def buildChildren
			if !isLeaf?
				children = JavaFX::FXCollections.observableArrayList
				case @data
				when Hash
					@data.each do |k,v|
						item = PKMNEE::Control::DataTreeItem.new( [k.to_s, simpleType(v)], v)
						children.add(item)
					end
				when Array
					@data.each.with_index do |e, i|
						item = PKMNEE::Control::DataTreeItem.new( [i.to_s, simpleType(e)], e)
						children.add(item)
					end
				else
					@data.instance_variables.each do |e|
						value = @data.instance_variable_get(e)
						item = PKMNEE::Control::DataTreeItem.new( [e.to_s, simpleType(value)], value)
						children.add(item)
					end
				end
			else
				children = JavaFX::FXCollections.emptyObservableList
			end
			children
		end
	end
end
