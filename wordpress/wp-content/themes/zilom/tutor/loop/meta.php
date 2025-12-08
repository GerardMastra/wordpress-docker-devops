<?php
/**
 * @package TutorLMS/Templates
 * @version 1.4.3
 */

global $post, $authordata;

$profile_url = tutor_utils()->profile_url($authordata->ID);
$course_students = tutor_utils()->count_enrolled_users_by_course();

?>

<div class="course-loop-meta">
    <div class="tutor-course-lising-category hidden">
        <?php
            $course_categories = get_tutor_course_categories();
            if(!empty($course_categories) && is_array($course_categories ) && count($course_categories)){
                foreach ($course_categories as $course_category){
                    $category_name = $course_category->name;
                    $category_link = get_term_link($course_category->term_id);
                    echo "<a href='$category_link'>$category_name </a>";
                }
            }
        ?>
    </div>
</div>
