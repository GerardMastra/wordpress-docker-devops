<?php
/**
 * @package TutorLMS/Templates
 * @version 1.4.3
 */

global $post;
$currentPost = $post;

$course = tutor_utils()->get_course_by_quiz(get_the_ID());
$previous_attempts = tutor_utils()->quiz_attempts();
$attempted_count = is_array($previous_attempts) ? count($previous_attempts) : 0;

$attempts_allowed = tutor_utils()->get_quiz_option(get_the_ID(), 'attempts_allowed', 0);
$passing_grade = tutor_utils()->get_quiz_option(get_the_ID(), 'passing_grade', 0);

$attempt_remaining = $attempts_allowed - $attempted_count;

do_action('tutor_quiz/single/before/top');

?>

<div class="tutor-quiz-header">
    <span class="tutor-quiz-badge"><?php echo esc_html__('Quiz', 'zilom'); ?></span>
    <h2 class="quiz-title"><?php echo get_the_title(); ?></h2>
    <h5 class="course-title">
		<?php echo esc_html__('Course', 'zilom'); ?> :
        <a href="<?php echo get_the_permalink($course->ID); ?>"><?php echo get_the_title($course->ID); ?></a>
    </h5>
    <ul class="tutor-quiz-meta">

		<?php
		$total_questions = tutor_utils()->total_questions_for_student_by_quiz(get_the_ID());

		if($total_questions){
			?>
            <li>
                <strong><?php echo esc_html__('Questions', 'zilom'); ?> :</strong>
				<?php echo esc_html($total_questions); ?>
            </li>
			<?php
		}

		$time_limit = tutor_utils()->get_quiz_option(get_the_ID(), 'time_limit.time_value');
		if ($time_limit){
			$time_type = tutor_utils()->get_quiz_option(get_the_ID(), 'time_limit.time_type');
			?>
            <li>
                <strong><?php echo esc_html__('Time', 'zilom'); ?> :</strong>
				<?php echo esc_html($time_limit) . ' ' . esc_html($time_type); ?>
            </li>
			<?php
		}

		?>
        <li>
            <strong><?php echo esc_html__('Attempts Allowed', 'zilom'); ?> :</strong>
            <?php 
               if($attempts_allowed == 0){ 
                  echo esc_html__('No limit', 'zilom');
               }else{
                  echo html_entity_decode($attempts_allowed);
               }
            ?>
        </li>
	    <?php

		if($attempted_count){
			?>
            <li>
               <strong><?php echo esc_html__('Attempted', 'zilom'); ?> :</strong>
				  <?php echo esc_html($attempted_count); ?>
            </li>
			<?php
		}
		?>
        <li>
            <strong><?php echo esc_html__('Attempts Remaining', 'zilom'); ?> :</strong>
            <?php 
               if($attempts_allowed == 0){ 
                  echo esc_html__('No limit', 'zilom');
               }else{
                  echo html_entity_decode($attempt_remaining);
               }
            ?>
        </li>
		<?php
		if($passing_grade){
			?>
            <li>
                <strong><?php echo esc_html__('Passing Grade', 'zilom'); ?> :</strong>
				<?php echo esc_html($passing_grade) . '%'; ?>

            </li>
			<?php
		}
		?>
    </ul>
</div>

<?php do_action('tutor_quiz/single/after/top'); ?>
