<?php

namespace App\Notifications;

use App\Website;
use App\CertificateScan;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\SlackMessage;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;

class CertificateIsWeak extends Notification
{
    use Queueable;

    /**
     * @var Website
     */
    private $website;

    /**
     * @var CertificateScan
     */
    private $scan;

    /**
     * Create a new notification instance.
     *
     * @param Website $website
     * @param CertificateScan $scan
     */
    public function __construct(Website $website, CertificateScan $scan)
    {
        $this->website = $website;
        $this->scan = $scan;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function via($notifiable)
    {
        return ['database', 'mail', 'slack'];
    }

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject('🔒 SSL is ineffective on: ' . $this->website->url)
            ->markdown('mail.ssl-weak', [
                'website' => $this->website,
                'scan' => $this->scan,
            ]);
    }

    public function toSlack($notifiable)
    {
        return (new SlackMessage)
            ->from('Odin', ':scream:')
            ->to(env('SLACK_CHANNEL') ?? '')
            ->content('🔒 SSL is ineffective on: ' . $this->website->url);
    }

    /**
     * Get the array representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function toArray($notifiable)
    {
        return [
            'website_id' => $this->website->id,
            'website' => $this->website->certificate_hostname,
            'was_valid' => $this->scan->was_valid,
            'did_expire' => $this->scan->did_expire,
            'grade' => $this->scan->grade,
        ];
    }
}
