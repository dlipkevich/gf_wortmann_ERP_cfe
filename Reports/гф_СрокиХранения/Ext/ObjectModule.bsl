﻿Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке();
	
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительныйОтчет();
	ПараметрыРегистрации.Наименование = "Сроки Хранения (гф)";
	ПараметрыРегистрации.Версия = "1.0";
	ПараметрыРегистрации.БезопасныйРежим = Ложь;
	ПараметрыРегистрации.Информация = "Сроки хранения"; 
	
    Возврат ПараметрыРегистрации;
	
КонецФункции


Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	ПараметрДатаОтчета = КомпоновкаДанныхКлиентСервер.ПолучитьПараметр(КомпоновщикНастроек, "ДатаОтчета");
	ПараметрыДанных = КомпоновщикНастроек.Настройки.ПараметрыДанных;
	ПараметрыДанных.УстановитьЗначениеПараметра("ГраницаДатаОтчета", Новый Граница(КонецДня(ПараметрДатаОтчета.Значение), ВидГраницы.Включая));
КонецПроцедуры

