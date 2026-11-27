-- Явне надання права виконання допоміжних функцій для ролей authenticated і service_role.
-- Необхідно на чистих інстансах БД після відкликання EXECUTE у public / anon в попередній міграції.
grant execute on function public.my_profile_id() to authenticated, service_role;
grant execute on function public.my_role() to authenticated, service_role;
