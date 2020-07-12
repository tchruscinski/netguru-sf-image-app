/**
* Scheduler class for the ImageApiService class
 */
global class ImageApiServiceScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        ImageApiService.fetchPhotos();
    }
}