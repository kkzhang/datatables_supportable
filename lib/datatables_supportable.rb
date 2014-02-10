require "datatables_supportable/version"

module DatatablesSupportable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

    attr_accessor :total_count

    def datatables(params, columns)

      self.total_count = self.count

      #filtering

      if (params.has_key? :sSearch) and not params[:sSearch].empty?
        _cond = ""
        columns.each_with_index do |c,index|
          if index+1 == columns.length
            _cond += "#{c} LIKE ?"
          else
            _cond += "#{c} LIKE ? OR "
          end
        end
        @comps = where(_cond, *Array.new(columns.length,"%#{params[:sSearch]}%"))
      else
        @comps = self
      end



      #ordering
      if params.has_key? :iSortCol_0
        params[:iSortingCols].to_i.times do |index|
          if params["bSortable_#{index}"]=='true'
            if params.has_key? "sSortDir_#{index}"
              _order = params["sSortDir_#{index}"]
              if _order == 'asc'
                @comps = @comps.order(columns[index])
              else
                @comps = @comps.order(columns[index]=>:desc)
              end
            end
          end
        end
      end

      # pagination
      if (params.has_key? :iDisplayStart) and (params.has_key? :iDisplayLength)
        @comps = @comps.offset(params[:iDisplayStart]).limit(params[:iDisplayLength])
      end

      @comps
    end


    def as_datatables_json(params)

      @datatables_columns = []
      @datatables_columns_idx = 0
      @datatables_mappings = {}
      yield self


      @comps = datatables(params, @datatables_columns)
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
            c[$1.to_sym]
          end

        end
        _d[:aaData] << _temp
      end

      _d
    end

    def searchable(columns)

      columns.each do |c|
        @datatables_columns << c
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