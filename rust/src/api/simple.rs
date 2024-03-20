use std::env::temp_dir;
use std::fmt::Error;
use std::num::ParseFloatError;
use std::process::Command;
use image::{GenericImageView, ImageBuffer, Rgb, RgbImage};

/// Generate the image of size [pixel_width] * video time in seconds x [height] from
/// the video at [path] based on the frames at each [interval] seconds.
#[flutter_rust_bridge::frb(sync)]
pub fn generate_image(path: String, interval: u32, pixel_width: u32, height: u32) {
    let pixels = get_colors_of_frames(path, interval)
        .expect("Failed to get pixels of frames");

    let width: u32 = pixels.len() as u32 * pixel_width;

    let mut result: RgbImage = ImageBuffer::new(width, height);

    let mut current_pixel = 0;

    for x in 0..width {
        for y in 0..height {
            result.put_pixel(x, y, Rgb([
                pixels[current_pixel].0,
                pixels[current_pixel].1,
                pixels[current_pixel].2
            ]));
        }

        if (x + 1) % pixel_width == 0 {
            current_pixel += 1;
        }
    }

    let save_path = temp_dir().as_path().join("output.jpg");
    result.save(save_path).expect("Failed to save final image");
}

/// Extract the average colors of each frame at each [interval] seconds.
fn get_colors_of_frames(path: String, interval: u32) -> Result<Vec<(u8, u8, u8)>, Error> {
    let length = get_video_seconds(&path).expect("Failed to get video seconds");

    let mut pixels: Vec<(u8, u8, u8)> = Vec::new();

    for i in 0..length {
        if i % interval == 0 {
            get_frame_at_time(&path, &format_seconds(i));
            let frame_path = temp_dir().as_path().join("frame.jpg");
            let img = image::open(frame_path).expect("Failed to open frame image");
            let pixel = average_color_in_image(&img).expect("Failed to get pixel");
            pixels.push(pixel);
        }
    }

    Ok(pixels)
}

/// Format the number of seconds to HH:MM:SS.
fn format_seconds(seconds: u32) -> String {
    let hours = (seconds as f32 / 3600.0) as i32;
    let minutes = ((seconds as f32 / 60.0) % 60.0) as i32;
    let seconds = (seconds as f32 % 60.0) as i32;
    format!("{:02}:{:02}:{:02}", hours, minutes, seconds)
}

/// Get the length of the video in seconds
#[flutter_rust_bridge::frb(sync)]
fn get_video_seconds(path: &String) -> Result<u32, Error> {
    let output = Command::new("ffprobe").args(&["-v", "error", "-show_entries", "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", &*path]).output().expect("failed");
    let result = stdout_to_int(output.stdout).expect("Failed to get video length");
    Ok(result)
}

/// This function is only used in calls from the Dart code.
///
/// The helper function was needed due to an issue with &String and
/// &str parameters.
pub fn get_video_seconds_helper(path: String) -> u32 {
    get_video_seconds(&path).expect("Failed to get video seconds")
}

/// Get the average color of the [img] as an RGB tuple
fn average_color_in_image(img: &image::DynamicImage) -> Result<(u8, u8, u8), Error> {
    let (width, height) = img.dimensions();
    let total_pixels = width * height;

    let sum = img.pixels().fold((0.0, 0.0, 0.0), |acc, p| {
        (
            acc.0 + p.2[0] as f32,
            acc.1 + p.2[1] as f32,
            acc.2 + p.2[2] as f32,
        )
    });

    let pixel_average = (
        (sum.0 / total_pixels as f32) as u8,
        (sum.1 / total_pixels as f32) as u8,
        (sum.2 / total_pixels as f32) as u8,
    );

    Ok(pixel_average)
}

/// Extract a frame from the video at the given [time].
///
/// The [time] should be formatted as HH:MM:SS.
fn get_frame_at_time(path: &String, time: &String) {
    Command::new("ffmpeg")
        .args(&["-y", "-i", &*path, "-ss", &*time, "-vframes", "1", "frame.jpg"])
        .current_dir(&temp_dir())
        .output()
        .expect("Failed to extract frame at time");
}

/// Convert the [input] from stdout format to a u32 integer
fn stdout_to_int(input: Vec<u8>) -> Result<u32, ParseFloatError> {
    let stdout = String::from_utf8_lossy(&input).to_string();
    let value = stdout.split("\n").collect::<Vec<&str>>()[0].trim();
    let parsed = value.parse::<f32>().expect("Failed to parse float");
    Ok(parsed as u32)
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
