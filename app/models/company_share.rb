class CompanyShare < ApplicationRecord
  belongs_to :parent, class_name: 'Company', inverse_of: :child_companies
  belongs_to :child, class_name: 'Company', inverse_of: :parent_companies
end
