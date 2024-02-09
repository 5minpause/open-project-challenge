#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2024 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

class Company < ApplicationRecord
  belongs_to :owner, class_name: 'User'

  has_many :parent_company_shares, class_name: 'CompanyShare', foreign_key: :child_id
  has_many :parent_companies, through: :parent_company_shares, source: :parent

  has_many :child_company_shares, class_name: 'CompanyShare', foreign_key: :parent_id
  has_many :child_companies, through: :child_company_shares, source: :child

  def owningUsers
    users = User.where(id: Company.joins(:owner).where("companies.id IN (#{parents_sql(self)})").pluck(:owner_id))
    users.any? ? users : [owner]
  end

  private

  def parents_sql(company)
    <<-SQL
    WITH RECURSIVE company_tree(parent_id, active, path) AS (
      SELECT parent_id, active, ARRAY[parent_id]
      FROM company_shares AS cs
      WHERE cs.child_id = #{company.id} AND cs.active = true
    UNION ALL
      SELECT cs.parent_id, cs.active, path || cs.parent_id
      FROM company_shares AS cs
      JOIN company_tree ON cs.child_id = company_tree.parent_id
      WHERE cs.active = true AND NOT cs.parent_id = ANY(path)
    )
    SELECT ct.path[array_length(ct.path, 1)] AS last_parent_id
    FROM company_tree ct
    WHERE NOT EXISTS (
      SELECT 1
      FROM company_shares cs
      WHERE cs.child_id = ct.path[array_length(ct.path, 1)] AND cs.active = true
    )
    GROUP BY ct.path
    ORDER BY ct.path
    SQL
  end
end
