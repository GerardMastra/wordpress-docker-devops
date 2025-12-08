<?php

/**
 * Template for displaying courses
 *
 * @since v.1.0.0
 *
 * @author Themeum
 * @url https://themeum.com
 *
 * @package TutorLMS/Templates
 * @version 1.5.8
 */

get_header();


?>

	<section id="wp-main-content" class="clearfix main-page title-layout-standard">
		<?php do_action( 'zilom_before_page_content' ); ?>
			<div class="container">	
		   	<div class="main-page-content course-archive">
		      	<div class="row">

			      	<!-- Main content -->
			      	<div class="content-page col-12">      
			  			  	<div id="wp-content" class="wp-content">
			  <div class="el-course-filter <?php echo esc_attr($layout) ?>">
								 	<?php if($course_filter && count($supported_filters)){ ?>
									<div class="tutor-course-filter-wrapper cleafix">
											<div class="tutor-course-filter-container clearfix">
												<span class="filter-top"><a href="#" class="btn-close-filter"><i class="fas fa-times"></i></a></span>
												<?php tutor_load_template('course-filter.filters'); ?>
											</div>			  		
											<div class="filter-course-results clearfix">
                  						<a href="#" class="btn-control-sidebar btn-theme"><?php echo esc_html__('Show Sidebar', 'zilom') ?></a>
												<div class="<?php tutor_container_classes(); ?> tutor-course-filter-loop-container" data-column_per_row="<?php echo tutor_utils()->get_option( 'courses_col_per_row', 4 ); ?>">
													<?php tutor_load_template('archive-course-init'); ?>
												</div><!-- .wrap -->
											</div>
										</div>
									<?php }else{ ?>
										<div class="filter-course-results clearfix">
											<div class="<?php tutor_container_classes(); ?>">
												<?php tutor_load_template('archive-course-init'); ?>
											</div>
										</div>	
									<?php } ?>
								</div>		
							</div>	
						</div>	

					</div>	
				</div>
			</div>				
		<?php do_action( 'zilom_after_page_content' ); ?>
	</section>

<?php get_footer(); ?>