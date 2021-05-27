from django.urls import path
from . import views, api, pdf

urlpatterns = [
	path('', views.index, name='index'),
	path('setscanfile/<scanfile>', views.setscanfile, name='setscanfile'),
	path('<address>/', views.details, name='details'),
	path('port/<port>/', views.port, name='port'),
	path('service/<filterservice>/', views.index, name='service'),
	path('portid/<filterportid>/', views.index, name='portid'),
	path('api/setlabel/<objtype>/<label>/<hashstr>/', api.label, name='api_label'),
	path('api/rmlabel/<objtype>/<hashstr>/', api.rmlabel, name='api_rmlabel'),
	path('api/pdf/', api.genPDF, name='genPDF'),
	path('api/savenotes/', api.saveNotes, name='genPDF'),
	path('api/rmnotes/<hashstr>/', api.rmNotes, name='api_rmnotes'),
	path('api/<address>/<portid>/', api.port_details, name='api_port'),
	path('view/pdf/', pdf.reportPDFView, name='reportPDFView')
]
