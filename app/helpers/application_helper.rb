module ApplicationHelper
include SavageBeast::ApplicationHelper

def beast_user_link
    if current_user
       link_to beast_user_name, :controller => "main", :action => "personalPage"
    else
       link_to beast_user_name, "#"
    end
end

end
