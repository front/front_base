<?php

/**
 * implements hook_install_configure_form_alter()
 */
function front_base_form_install_configure_form_alter(&$form, &$form_state) {
  $form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME']; 
  $form['site_information']['site_mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST']; 
  $form['admin_account']['account']['name']['#default_value'] = 'admin';
  $form['admin_account']['account']['mail']['#default_value'] = 'front@front.no'; 
}


/**
 * hook_install_tasks()
 */
function front_base_install_tasks() {
  $task['basic_roles'] = array(
    'display_name' => st('Install default roles (administrator & editor)'),
    'display' => FALSE,
    'type' => 'normal',
    'run' => INSTALL_TASK_RUN_IF_REACHED,
    'function' => 'front_base_create_basic_roles_perms',
  );
  $task['admin_theme'] = array(
    'display_name' => st('Set admin theme'),
    'display' => FALSE,
    'type' => 'normal',
    'run' => INSTALL_TASK_RUN_IF_REACHED,
    'function' => 'front_base_enable_admin_theme',
  );
  $task['other_setup_tasks'] = array(
    'display_name' => st('Other setup tasks'),
    'display' => FALSE,
    'type' => 'normal',
    'run' => INSTALL_TASK_RUN_IF_REACHED,
    'function' => 'front_base_other_setup_tasks',
  );	
  return $task;
}

/** 
 * Create 2 default roles
 */
function front_base_create_basic_roles_perms() {
  //1)  Create a default role for site administrators, with all available permissions assigned.
  $admin_role = new stdClass();
  $admin_role->name = 'administrator';
  $admin_role->weight = 2;
  user_role_save($admin_role);
  user_role_grant_permissions($admin_role->rid, array_keys(module_invoke_all('permission')));
  // Set this as the administrator role.
  variable_set('user_admin_role', $admin_role->rid);

  // Assign user 1 the "administrator" role.
  db_insert('users_roles')
    ->fields(array('uid' => 1, 'rid' => $admin_role->rid))
    ->execute();  
	
	//2) Create an editor role with some default permissions
  $admin_role = new stdClass();
  $admin_role->name = 'Editor';
  $admin_role->weight = 3;
  user_role_save($admin_role);
  $permissions = array(
    'access administration pages',
    'access all views',
    'access all webform results',
    'access content overview',
    'access contextual links',
    'access dashboard',
    'access overlay',
    'access own webform results',
    'access own webform submissions',
    'access site in maintenance mode',
    'access site reports',
    'access statistics',
    'access toolbar',
    'access user profiles',
    'administer comments',
    'administer menu',
    'administer nodequeue',
    'administer search',
    'administer shortcuts',
    'administer taxonomy',
    'administer url aliases',
    'bypass node access',
    'create author content',
    'create blog_entry content',
    'create home_page_feature content',
    'create press_release content',
    'create resource content',
    'create section_front content',
    'create services content',
    'create site_page content',
    'create url aliases',
    'create webform content',
    'customize shortcut links',
    'delete all webform submissions',
    'delete any author content',
    'delete any blog_entry content',
    'delete any home_page_feature content',
    'delete any press_release content',
    'delete any resource content',
    'delete any section_front content',
    'delete any services content',
    'delete any site_page content',
    'delete any webform content',
    'delete own author content',
    'delete own blog_entry content',
    'delete own home_page_feature content',
    'delete own press_release content',
    'delete own resource content',
    'delete own section_front content',
    'delete own services content',
    'delete own site_page content',
    'delete own webform content',
    'delete own webform submissions',
    'delete revisions',
    'display source code',
    'edit all webform submissions',
    'edit any author content',
    'edit any blog_entry content',
    'edit any home_page_feature content',
    'edit any press_release content',
    'edit any resource content',
    'edit any section_front content',
    'edit any services content',
    'edit any site_page content',
    'edit any user follow links',
    'edit any webform content',
    'edit own author content',
    'edit own blog_entry content',
    'edit own comments',
    'edit own follow links',
    'edit own home_page_feature content',
    'edit own press_release content',
    'edit own resource content',
    'edit own section_front content',
    'edit own services content',
    'edit own site_page content',
    'edit own webform content',
    'edit own webform submissions',
    'edit site follow links',
    'manipulate all queues',
    'manipulate queues',
    'revert revisions',
    'search content',
    'skip comment approval',
    'use advanced search',
    'use text format filtered_html',
    'use text format full_html',
    'view addthis',
    'view date repeats',
    'view own unpublished content',
    'view pane admin links',
    'view post access counter',
    'view revisions',
    'view the administration theme',
  );
  user_role_grant_permissions($admin_role->rid, $permissions);
  // Set this as the editor role.
  variable_set('user_editor_role', $admin_role->rid);

}

/**
* Set Rubik as the Admin Theme
*/
function front_base_enable_admin_theme() {
  // Enable the admin theme.
  db_update('system')
    ->fields(array('status' => 1))
    ->condition('type', 'theme')
    ->condition('name', 'seven')
    ->execute();
  db_update('system')
    ->fields(array('status' => 1))
    ->condition('type', 'theme')
    ->condition('name', 'rubik')
    ->execute();
  variable_set('admin_theme', 'rubik');
  variable_set('node_admin_theme', '1');
}

/**
 * 
 */
function front_base_other_setup_tasks() {
	// set various system variables
  // Allow visitor account creation with administrative approval.
  variable_set('user_register', USER_REGISTER_VISITORS_ADMINISTRATIVE_APPROVAL);
  variable_set('pathauto_node_pattern', '[node:type]/[node:title]');
  variable_set('pathauto_node_blog_entry_pattern', 'blog/[node:created:custom:Y-m-d]/[node:title]');
  variable_set('pathauto_punctuation_underscore', '1');
}

