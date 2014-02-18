require "datatables_supportable/version"

module DatatablesSupportable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

    attr_accessor :total_count

    def datatables(params, orderable_columns, searchable_columns)

      self.total_count = self.count

      @comps = self

      #filtering


      if searchable_columns.length > 0
        if (params.has_key? :sSearch) and not params[:sSearch].empty?
          _cond = ""
          searchable_columns.each_with_index do |c,index|
            if index+1 == searchable_columns.length
              _cond += "#{c} LIKE ?"
            else
              _cond += "#{c} LIKE ? OR "
            end
          end
          @comps = where(_cond, *Array.new(searchable_columns.length,"%#{params[:sSearch]}%"))
        end
      end


      #ordering
      if params[:iSortingCols].to_i > 0
      #  params[:iSortingCols].to_i.times do |index|
      #      idx =  params["iSortCol_#{index}"].to_i
      #      if params.has_key? "sSortDir_#{index}"
      #        _order = params["sSortDir_#{index}"]
      #        if _order == 'asc'
      #          @comps = @comps.order(orderable_columns[:index][idx])
      #        else
      #          @comps = @comps.order(orderable_columns[:index][idx]=>:desc)
      #        end
      #      end
      #  end
      end

      if orderable_columns.has_key? :default
        orderable_columns[:default].each do |order|
          @comps = @comps.order(order[0]=>order[1])
        end
      end


      # pagination
      if (params.has_key? :iDisplayStart) and (params.has_key? :iDisplayLength)
        @comps = @comps.offset(params[:iDisplayStart]).limit(params[:iDisplayLength])
      end

      @comps
    end


    def as_datatables_json(params)

      @searchable_columns = []
      @orderable_columns = {:default=>[],:index=>[]}
      @datatables_columns_idx = 0
      @datatables_mappings = {}
      yield self


      @comps = datatables(params, @orderable_columns, @searchable_columns)
      _d = {:sEcho=>params[:sEcho],
            :iTotalRecords=>@comps.length,
            :iTotalDisplayRecords=>@comps.total_count,
            :aaData=>[],
            :DT_RowClass=>""
      }

      @comps.map do |c|
        _temp = {}

        @datatables_mappings.each_pair do |key,value|
          _temp[key] = value.gsub(/\[\$([^\]]+)\]/) do |word|
            c.send $1.to_sym
          end

        end
        _d[:aaData] << _temp
      end

      _d
    end

    def searchable(*columns)
      @searchable_columns = columns
    end

    def orderable(columns)
      columns.each_pair do |k,v|
        if v.kind_of? Array
          @orderable_columns[k]<<v
        else
          @orderable_columns[:index][k] = v
        end

      end

    end

    def set_row(options={})
      options = options.symbolize_keys
      if not options.has_key? :name

        if options.has_key? :column
          @datatables_mappings[@datatables_columns_idx] = "[$#{options[:column]}]"
        else
          @datatables_mappings[@datatables_columns_idx] = value
        end

        @datatables_columns_idx += 1
      else
        @datatables_mappings[options[:name]] = options[:value]
      end
    end
  end
end

ActiveRecord::Base.send :include, DatatablesSupportable