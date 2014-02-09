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
  end
end

ActiveRecord::Base.send :include, DatatablesSupportable