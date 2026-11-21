-- Replace the email below with the account email to promote.
-- Run this separately in the Supabase SQL Editor.
update public.profiles p
set role_id = r.id
from public.roles r
where r.role = 'admin'
  and lower(p.email) = lower('jybyamota@addu.edu.ph');
