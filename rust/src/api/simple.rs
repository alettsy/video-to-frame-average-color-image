use std::env::temp_dir;
use std::fmt::Error;
use std::num::ParseFloatError;
use std::process::Command;
use image::{GenericImageView, ImageBuffer, Rgb, RgbImage};

use crate::frb_generated::StreamSink;

#[derive(Clone)]
pub struct ImageGenerator {
    pub frame_path: String,
    pub path: String,
    pub interval: u32,
    pub pixel_width: u32,
    pub height: u32,
    pub width: u32,
    pub length_in_seconds: u32,
    pub current_time: u32,
}

impl ImageGenerator {
    /// Create a new [ImageGenerator] based on the [path] of the video, the [interval] in seconds
    /// to use, the [pixel_width] of each interval and the [height] of the image.
    #[flutter_rust_bridge::frb(sync)]
    pub fn new(path: String, interval: u32, pixel_width: u32, height: u32) -> ImageGenerator {
        let mut generator = ImageGenerator {
            frame_path: temp_dir().as_path().join("frame.jpg").to_str().unwrap().to_string(),
            path,
            interval,
            pixel_width,
            height,
            width: 0,
            length_in_seconds: 0,
            current_time: 0,
        };

        let length = get_video_seconds(&generator.path).expect("Failed to get video seconds");

        generator.length_in_seconds = length;
        generator.width = (generator.length_in_seconds / generator.interval) * generator.pixel_width;
        generator
    }

    /// Generate the image of size [pixel_width] * video time in seconds x [height] from
    /// the video at [path] based on the frames at each [interval] seconds.
    #[flutter_rust_bridge::frb(sync)]
    pub fn generate_image(&self, sink: StreamSink<u32>) {
        let pixels = self.get_colors_of_frames(sink).expect("Failed to get colors of frames");

        let mut result: RgbImage = ImageBuffer::new(self.width, self.height);

        let mut current_pixel = 0;

        for x in 0..self.width {
            for y in 0..self.height {
                result.put_pixel(x, y, Rgb([
                    pixels[current_pixel].0,
                    pixels[current_pixel].1,
                    pixels[current_pixel].2
                ]));
            }

            if (x + 1) % self.pixel_width == 0 {
                current_pixel += 1;
            }
        }

        let save_path = temp_dir().as_path().join("output.jpg");
        result.save(save_path).expect("Failed to save final image");
    }

    /// Extract the average colors of each frame at each [interval] seconds.
    ///
    /// Uses a [sink] to yield how many frames have been processed for Dart to show a progress
    /// indicator.
    fn get_colors_of_frames(&self, sink: StreamSink<u32>) -> Result<Vec<(u8, u8, u8)>, Error> {
        let mut pixels: Vec<(u8, u8, u8)> = Vec::new();

        let mut processed: u32 = 0;

        for i in 0..self.length_in_seconds {
            if i % self.interval == 0 {
                self.get_frame_at_time(&self.format_seconds(i));
                let frame_path = temp_dir().as_path().join("frame.jpg");
                let img = image::open(frame_path).expect("Failed to open frame image");
                let pixel = self.average_color_in_image(&img).expect("Failed to get pixel");
                pixels.push(pixel);
                processed += 1;
                sink.add(processed);
            }
        }

        Ok(pixels)
    }

    /// Extract a frame from the video at the given [time].
    ///
    /// The [time] should be formatted as HH:MM:SS.
    fn get_frame_at_time(&self, time: &String) {
        Command::new("ffmpeg")
            .args(&["-y", "-i", &*self.path, "-ss", &*time, "-vframes", "1", "frame.jpg"])
            .current_dir(&temp_dir())
            .output()
            .expect("Failed to extract frame at time");
    }

    /// This function is only used in calls from the Dart code.
    ///
    /// The helper function was needed due to an issue with &String and
    /// &str parameters.
    #[flutter_rust_bridge::frb(sync)]
    pub fn get_video_seconds_helper(&self) -> u32 {
        get_video_seconds(&self.path).expect("Failed to get video seconds")
    }

    /// Format the number of [seconds] to HH:MM:SS.
    fn format_seconds(&self, seconds: u32) -> String {
        let hours = (seconds as f32 / 3600.0) as i32;
        let minutes = ((seconds as f32 / 60.0) % 60.0) as i32;
        let seconds = (seconds as f32 % 60.0) as i32;
        format!("{:02}:{:02}:{:02}", hours, minutes, seconds)
    }

    /// Get the average color of the [img] as an RGB tuple
    fn average_color_in_image(&self, img: &image::DynamicImage) -> Result<(u8, u8, u8), Error> {
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

    /// Return the length of the video in seconds.
    pub fn get_video_length(&self) -> u32 {
        self.length_in_seconds
    }
}

/// This function is only used in calls from the Dart code.
///
/// The helper function was needed due to an issue with &String and
/// &str parameters.
pub fn get_video_seconds_helper(path: String) -> u32 {
    get_video_seconds(&path).expect("Failed to get video seconds")
}

/// Get the length of the video in seconds using ffmpeg.
fn get_video_seconds(path: &String) -> Result<u32, Error> {
    let output = Command::new("ffprobe").args(&["-v", "error", "-show_entries", "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", &*path]).output().expect("failed");
    let result = stdout_to_int(output.stdout).expect("Failed to get video length");
    Ok(result)
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
