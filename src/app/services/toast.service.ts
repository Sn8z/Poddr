import { Injectable } from "@angular/core";
import { shell } from 'electron';
import Swal from 'sweetalert2';
import * as log from 'electron-log';

@Injectable({
	providedIn: "root"
})
export class ToastService {
	private toastTemplate: any = Swal.mixin({
		toast: true,
		timer: 5000,
		timerProgressBar: true,
		position: 'top-end',
		showConfirmButton: false,
		customClass: {
			popup: 'toast-popup-class'
		}
	});

	private modalTemplate: any = Swal.mixin({
		showConfirmButton: false,
		customClass: {
			popup: 'modal-popup-class',
			title: 'modal-title-class',
			htmlContainer: 'modal-container-class',
			confirmButton: 'swal-confirm-btn',
			validationMessage: 'swal-validation',
			input: 'swal-input'
		}
	});

	constructor() { }

	// Toasts
	public toast = (msg: string = "", timer: number = 5000): void => {
		log.info("Toast service :: Showing toast => " + msg);
		this.toastTemplate.fire({
			title: msg,
			timer: timer
		});
	}

	public toastURL = (msg: string = "", url: string = "", timer: number = 5000): void => {
		log.info("Toast service :: Showing toast => " + msg);
		this.toastTemplate.fire({
			icon: 'warning',
			title: msg,
			timer: timer,
			customClass: {
				popup: 'toast-popup-update-class'
			},
			didOpen: (toast) => {
				toast.addEventListener('click', () => {
					shell.openExternal(url);
				})
			}
		});
	}

	public toastSuccess = (msg: string = ""): void => {
		log.info("Toast service :: Showing success toast => " + msg);
		this.toastTemplate.fire({
			icon: 'success',
			title: msg
		});
	}

	public toastError = (msg: string = ""): void => {
		log.info("Toast service :: Showing error toast => " + msg);
		this.toastTemplate.fire({
			icon: 'error',
			title: msg
		});
	}

	//Modals
	public modal = (title: string = "", msg: string = ""): void => {
		log.info("Toast service :: Showing modal.");
		this.modalTemplate.fire({
			title: title,
			text: msg
		});
	}

	public errorModal = (error: string = "Something went wrong."): void => {
		log.info("Toast service :: Showing error modal.");
		this.modalTemplate.fire({
			icon: 'error',
			text: error
		});
	}

	// Confirmation
	public confirmModal = async (): Promise<any> => {
		log.info("Toast service :: Showing confirmation modal.");
		return await this.modalTemplate.fire({
			title: 'Are you sure?',
			icon: 'warning',
			showConfirmButton: true,
			showCancelButton: true,
			confirmButtonText: 'Yes, remove it!'
		});
	}

	//Inputs
	public inputRSSModal = async (): Promise<any> => {
		log.info("Toast service :: Showing input modal.");
		return await this.modalTemplate.fire({
			title: 'Enter RSS feed',
			input: 'url',
			inputPlaceholder: 'RSS feed...',
			showConfirmButton: true
		});
	}
}
