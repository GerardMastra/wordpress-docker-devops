<?php
/**
 * Template for displaying course content
 *
 * @since v.1.0.0
 *
 * @author Themeum
 * @url https://themeum.com
 *
 * @package TutorLMS/Templates
 * @version 1.4.3
 */

if ( ! defined( 'ABSPATH' ) )
	exit;
?>

<div class="tutor-price-preview-box">
   <div class="price-meta">
      <?php tutor_course_price(); ?>
      <?php tutor_single_course_add_to_cart(); ?>
   </div>
	<?php tutor_course_material_includes_html(); ?>

</div> <!-- tutor-price-preview-box -->
