require File.expand_path(File.dirname(__FILE__) + "/../../lib/white_list/lib/white_list_helper")
ActionView::Base.send :include, WhiteListHelper
