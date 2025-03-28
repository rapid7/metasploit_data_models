# -*- coding: binary -*-
class ConvertBinary < ActiveRecord::Migration[4.2]


	class WebPage < ApplicationRecord
		if ActiveRecord::VERSION::MAJOR >= 7 && ActiveRecord::VERSION::MINOR >= 1
			serialize :headers, coder: YAML
		else
			serialize :headers
		end
	end

	class WebVuln < ApplicationRecord
		if ActiveRecord::VERSION::MAJOR >= 7 && ActiveRecord::VERSION::MINOR >= 1
			serialize :params, coder: YAML
		else
			serialize :params
		end
	end

	def bfilter(str)
		str = str.to_s
		str.encoding = 'binary' if str.respond_to?('encoding=')
		str.gsub(/[\x00\x7f-\xff]/, '')
	end

	def self.up
		rename_column :web_pages, :body, :body_text
		rename_column :web_pages, :request, :request_text
		rename_column :web_vulns, :request, :request_text
		rename_column :web_vulns, :proof, :proof_text

		add_column :web_pages, :body, :binary
		add_column :web_pages, :request, :binary
		add_column :web_vulns, :request, :binary
		add_column :web_vulns, :proof, :binary

		WebPage.all.each { |r| r.body = r.body_text; r.save! }
		WebPage.all.each { |r| r.request = r.request_text; r.save! }
		WebVuln.all.each { |r| r.proof = r.proof_text; r.save! }
		WebVuln.all.each { |r| r.request = r.request_text; r.save! }

		remove_column :web_pages, :body_text
		remove_column :web_pages, :request_text
		remove_column :web_vulns, :request_text
		remove_column :web_vulns, :proof_text

		WebPage.connection.schema_cache.clear!
		WebPage.reset_column_information
		WebVuln.connection.schema_cache.clear!
		WebVuln.reset_column_information
	end

	def self.down

		rename_column :web_pages, :body, :body_binary
		rename_column :web_pages, :request, :request_binary
		rename_column :web_vulns, :request, :request_binary
		rename_column :web_vulns, :proof, :proof_binary

		add_column :web_pages, :body, :text
		add_column :web_pages, :request, :text
		add_column :web_vulns, :request, :text
		add_column :web_vulns, :proof, :text

		WebPage.all.each { |r| r.body = bfilter(r.body_binary); r.save! }
		WebPage.all.each { |r| r.request = bfilter(r.request_binary); r.save! }
		WebVuln.all.each { |r| r.proof = bfilter(r.proof_binary); r.save! }
		WebVuln.all.each { |r| r.request = bfilter(r.request_binary); r.save! }

		remove_column :web_pages, :body_binary
		remove_column :web_pages, :request_binary
		remove_column :web_vulns, :request_binary
		remove_column :web_vulns, :proof_binary

		WebPage.connection.schema_cache.clear!
		WebPage.reset_column_information
		WebVuln.connection.schema_cache.clear!
		WebVuln.reset_column_information
	end
end
