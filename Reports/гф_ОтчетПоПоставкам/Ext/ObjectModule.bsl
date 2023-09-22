﻿Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке();
	
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительныйОтчет();
	ПараметрыРегистрации.Наименование = "гф_ОтчетПоПоставкам";
	ПараметрыРегистрации.Версия = "1.0";
	ПараметрыРегистрации.БезопасныйРежим = Ложь;
	ПараметрыРегистрации.Информация = "Отчет по поставкам";
	
    Возврат ПараметрыРегистрации;
	
КонецФункции

//(н)Галфинд/Сефербеков 22.09.2023 ( 
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	ДопСвойство = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("ИдентификаторДляФормул", "гф_НоменклатураДекларация");
		
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	
	// 
	ЗначениеПоиска = Новый ПараметрКомпоновкиДанных("Свойство");
	парамСвойство = Настройки.ПараметрыДанных.НайтиЗначениеПараметра(ЗначениеПоиска);
	парамСвойство.Значение = ДопСвойство ;
	парамСвойство.Использование = Истина;
	//
		
	КомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
	
КонецПроцедуры

#КонецЕсли
//(к)Галфинд/Сефербеков 22.09.2023 ) 
