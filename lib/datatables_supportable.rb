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
        @comps = where(_cond, "%#{params[:sSearch]}%","%#{params[:sSearch]}%","%#{params[:sSearch]}%","%#{params[:sSearch]}%")
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
      @datatables_mappings = {:index=>{}, :additional=>{}}
      yield self


      @comps = datatables(params, @datatables_columns)
      _d = {:sEcho=>params[:sEcho],
            :iTotalRecords=>@comps.length,
            :iTotalDisplayRecords=>@comps.total_count,
            :aaData=>[],
            :DT_RowClass=>""
      }

      @comps.map do |c|
        @datatables_mappings[:index].each_pair do |key,value|
          if value.nil?
            _d[:aaData][key]
          end
          _d[:aaData][key] = c[value]
        end

        @datatables_mappings[:additional].each_pair do |key,value|
          _d[:aaData][key] = value
        end
      end

      _d
    end

    def set_row(options={})
      options = options.symbolize_keys
      if options.has_key? :column
        curr_length = @datatables_mappings[:index].length
        @datatables_mappings[:index][curr_length] = options[:column]

        if options.has_key? :searchable
          @datatables_columns << options[:column]
        end
      elsif options.has_key? :value
        if options.has_key? :name
          @datatables_mappings[:additional][name] = options[:value]
        else
          curr_length = @datatables_mappings[:index].length
          @datatables_mappings[:index][curr_length] = options[:value]
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, DatatablesSupportable