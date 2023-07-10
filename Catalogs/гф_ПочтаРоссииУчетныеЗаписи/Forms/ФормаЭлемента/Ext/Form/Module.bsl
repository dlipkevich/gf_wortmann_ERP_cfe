﻿// BSLLS:Typo-off
// Давайте мы будем сами, без шибко грамотного СонарКубе определять что грамотно, а что нет
// Трекер - нормальное слово.

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	УстановитьПривилегированныйРежим(Истина);
	
	ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(ТекущийОбъект.Ссылка, Пароль, "Пароль");
	ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(ТекущийОбъект.Ссылка, Токен, "Токен");
	ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(ТекущийОбъект.Ссылка, КлючАвторизации, "КлючАвторизации");
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Пароль          = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(Объект.Ссылка, "Пароль");
	Токен           = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(Объект.Ссылка, "Токен");
	КлючАвторизации = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(Объект.Ссылка, "КлючАвторизации");
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаСервере
Процедура КомандаПроверитьДоступКТрекеруНаСервере(Ошибки)
	
	ТрекНомер = "ER000000000RU";
	
	ОтветОтСервера = гф_ПочтаРоссии.ПолучитьДанныеОтслеживанияСлужебный(Объект.Логин, Пароль, ТрекНомер, Ошибки);
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПроверитьДоступКТрекеру(Команда)
	
	Ошибки = Новый Массив;
	
	КомандаПроверитьДоступКТрекеруНаСервере(Ошибки);
	
	Если Ошибки.Количество() Тогда
		
		ПоказатьПредупреждение(, "Проверка доступа к трекеру завершилась неудачно. Проверьте логин и пароль.");
		
	Иначе
		
		ПоказатьПредупреждение(, "Проверка доступа к терекеру прошла успешно.");
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура КомандаПроверитьДоступКОтправкеНаСервере(Ошибки)
	
	ПараметрыЗапроса = гф_ПочтаРоссии.ПараметрыЗапросаНормализацияАдреса();
	
	ПараметрыЗапроса.Вставить("Токен",           Токен);
	ПараметрыЗапроса.Вставить("КлючАвторизации", КлючАвторизации);
	
	ТекстЗапроса = "[]";
	
	ТекстОтвета = гф_ПочтаРоссии.ЗапросКОтправкеСлужебный(ПараметрыЗапроса, ТекстЗапроса, Ошибки);
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПроверитьДоступКОтправке(Команда)
	
	Ошибки = Новый Массив;
	
	КомандаПроверитьДоступКОтправкеНаСервере(Ошибки);
	
	Если Ошибки.Количество() Тогда
		
		ПоказатьПредупреждение(,
		"Проверка доступа к сервису отправки завершилась неудачно. Проверьте токен и ключ авторизации.");
		
	Иначе
		
		ПоказатьПредупреждение(, "Проверка доступа к сервису отправки прошла успешно.");
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

// BSLLS:Typo-on