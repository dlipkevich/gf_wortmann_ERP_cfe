﻿#Область ОбработчикиСобытийФормы

// #wortmann {
// #4.2.03
// Добавляем вызов создания полей контрагента, устанавливаем доступность группы доступа
// Галфинд Окунев 2022/07/05
&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)

	Если Не Пользователи.ЭтоПолноправныйПользователь() Тогда
		
		Элементы.ГруппаДоступа.Доступность = Ложь;
		Элементы.ГруппаДоступаЧастноеЛицо.Доступность = Ложь;
		
	КонецЕсли;	
	
	
	гф_СоздатьИЗаполнитьРеквизитыКонтрагента();
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #4.2.03
// Добавляем вызов создания полей контрагента
// Галфинд Окунев 2022/07/05
&НаСервере
Процедура гф_ПриЧтенииНаСервереПеред(ТекущийОбъект)

	гф_СоздатьИЗаполнитьРеквизитыКонтрагента(ТекущийОбъект);
	
КонецПроцедуры// } #wortmann


// #wortmann {
// #4.2.03
// Добавляет поля контрагента если еще не созданы
// если найден контрагент для партнера поля заполняются
// Галфинд Окунев 2022/07/05
// Параметры:
// Партнер - объект справочника Партнеры, для поиска которого получают данные контрагента 
&НаСервере
Процедура гф_СоздатьИЗаполнитьРеквизитыКонтрагента(Партнер = Неопределено)
	
	Если Элементы.Найти("гф_ОсновнойКонтрагент") = Неопределено Тогда
		
		ДобавляемыеРеквизиты = Новый Массив;
		
		КвалификаторыСтроки10	= Новый КвалификаторыСтроки(10);
		КвалификаторыСтроки13	= Новый КвалификаторыСтроки(13);
		КвалификаторыСтроки0	= Новый КвалификаторыСтроки(0);
		
		ОписаниеТиповСтрока10			= Новый ОписаниеТипов("Строка", , КвалификаторыСтроки10);
		ОписаниеТиповСтрока13			= Новый ОписаниеТипов("Строка", , КвалификаторыСтроки13);
		ОписаниеТиповСтрока0			= Новый ОписаниеТипов("Строка", , КвалификаторыСтроки0);
		ОписаниеТиповКонтрагенты		= Новый ОписаниеТипов("СправочникСсылка.Контрагенты");
		ОписаниеТиповБулево				= Новый ОписаниеТипов("Булево");        
		ОписаниеТиповТаблицаЗначений	= Новый ОписаниеТипов("ТаблицаЗначений");
		ОписаниеТиповАдресаДоставки		= Новый ОписаниеТипов("СправочникСсылка.гф_АдресаДоставки");		
		ОписаниеТиповОрганизации		= Новый ОписаниеТипов("СправочникСсылка.Организации");		
		ОписаниеТиповПользователи		= Новый ОписаниеТипов("СправочникСсылка.Пользователи");		
	
		РеквизитФормы_гф_Код				= Новый РеквизитФормы("гф_Код",
										ОписаниеТиповСтрока10, , "Код контрагента", Истина);
		РеквизитФормы_гф_Контрагент			= Новый РеквизитФормы("гф_Контрагент",
										ОписаниеТиповКонтрагенты, , "Контрагент", Истина);
		РеквизитФормы_гф_ОсновнойКонтрагент	= Новый РеквизитФормы("гф_ОсновнойКонтрагент",
										ОписаниеТиповКонтрагенты, ,"Основной контрагент", Истина);
		РеквизитФормы_гф_Логистика			= Новый РеквизитФормы("гф_Логистика",
										ОписаниеТиповБулево, ,"Логистика", Истина);
		РеквизитФормы_гф_РС_ГЛН_номер		= Новый РеквизитФормы("гф_RC_GLN_номер",
										ОписаниеТиповСтрока13, ,"RC_GLN_номер", Истина);
		РеквизитФормы_гф_Комментарий		= Новый РеквизитФормы("гф_Комментарий",
										ОписаниеТиповСтрока0, ,"Комментарий", Истина);
		РеквизитФормы_гф_Зарегистрирован	= Новый РеквизитФормы("гф_Зарегистрирован",
										ОписаниеТиповБулево, ,"Зарегистрирован", Истина);
		
		РеквизитФормы_гф_АдресаДоставки	= Новый РеквизитФормы("гф_АдресаДоставки",
										ОписаниеТиповТаблицаЗначений, ,"Адреса доставки", Истина);   
		РеквизитФормы_Адрес				= Новый РеквизитФормы("Адрес",
										ОписаниеТиповАдресаДоставки,"гф_АдресаДоставки", "Адрес", Истина);   

		РеквизитФормы_гф_ОтветственныйМенеджер	= Новый РеквизитФормы("гф_ОтветственныйМенеджер",
										ОписаниеТиповТаблицаЗначений, ,"Ответственный менеджер", Истина);   
		РеквизитФормы_Организация				= Новый РеквизитФормы("Организация",
										ОписаниеТиповОрганизации,"гф_ОтветственныйМенеджер", "Организация", Истина);   
		РеквизитФормы_Пользователь				= Новый РеквизитФормы("Пользователь",
										ОписаниеТиповПользователи,"гф_ОтветственныйМенеджер", "Пользователь", Истина);   
		
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Код);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Контрагент);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ОсновнойКонтрагент);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Логистика);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_РС_ГЛН_номер);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Комментарий);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_Зарегистрирован);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_АдресаДоставки);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_Адрес);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ОтветственныйМенеджер);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_Организация);
		ДобавляемыеРеквизиты.Добавить(РеквизитФормы_Пользователь);
		
		ИзменитьРеквизиты(ДобавляемыеРеквизиты);
		
		НовоеПоле = Элементы.Добавить("гф_ОсновнойКонтрагент", Тип("ПолеФормы"),
										Элементы.ГруппаНаименование);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОсновнойКонтрагент";  
		
		НовоеПоле = Элементы.Добавить("гф_Логистика", Тип("ПолеФормы"),
										Элементы.ГруппаОтношения);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеФлажка;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_Логистика";  
		
		НовоеПоле = Элементы.Добавить("гф_Зарегистрирован", Тип("ПолеФормы"),
										Элементы.ГруппаОтношения);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеФлажка;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_Зарегистрирован";  
		
		НовоеПоле = Элементы.Добавить("РеквизитФормы_гф_РС_ГЛН_номер", Тип("ПолеФормы"),
										Элементы.ГруппаИдентификация);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_RC_GLN_номер";  
		
		НовоеПоле = Элементы.Добавить("гф_Комментарий",Тип("ПолеФормы"), ЭтотОбъект);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_Комментарий";  
		
		НовоеПоле = Элементы.Добавить("гф_АдресаДоставки", Тип("ТаблицаФормы"),
										Элементы.ГруппаКонтактнаяИнформация);
		
		НовоеПоле.Видимость				= Истина;
		НовоеПоле.ПутьКДанным			= "гф_АдресаДоставки";
		НовоеПоле.Отображение			= ОтображениеТаблицы.Список;  
		НовоеПоле.ПоложениеЗаголовка	= ПоложениеЗаголовкаЭлементаФормы.Лево;
		
		НовоеПоле = Элементы.Добавить("гф_АдресаДоставки_Адрес", Тип("ПолеФормы"),
										Элементы.гф_АдресаДоставки);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_АдресаДоставки.Адрес";  
		
		НоваяСвязь = Новый СвязьПараметраВыбора("Отбор.Владелец", "гф_Контрагент");
		НовыйМассив = Новый Массив();
		НовыйМассив.Добавить(НоваяСвязь);
		НовоеПоле.СвязиПараметровВыбора	= Новый ФиксированныйМассив(НовыйМассив);

		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер",Тип("ТаблицаФормы"),
										Элементы.ГруппаОбщаяИнформация);
		
		НовоеПоле.Видимость				= Истина;
		НовоеПоле.ПутьКДанным			= "гф_ОтветственныйМенеджер";
		НовоеПоле.Отображение			= ОтображениеТаблицы.Список;  
		НовоеПоле.ПоложениеЗаголовка	= ПоложениеЗаголовкаЭлементаФормы.Лево;
		
		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер_Организация", Тип("ПолеФормы"),
										Элементы.гф_ОтветственныйМенеджер);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОтветственныйМенеджер.Организация";  
		
		НовоеПоле = Элементы.Добавить("гф_ОтветственныйМенеджер_Пользователь", Тип("ПолеФормы"),
										Элементы.гф_ОтветственныйМенеджер);
		
		НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость		= Истина;
		НовоеПоле.ПутьКДанным	= "гф_ОтветственныйМенеджер.Пользователь";  
		
	КонецЕсли;	      
	
	Если Партнер = Неопределено Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Запрос = Новый Запрос;  
	
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	Контрагенты.Ссылка КАК Ссылка
	               |ПОМЕСТИТЬ ВТ_Контрагенты
	               |ИЗ
	               |	Справочник.Контрагенты КАК Контрагенты
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Партнеры КАК Партнеры
	               |		ПО Контрагенты.Партнер = Партнеры.Ссылка
	               |			И (Партнеры.Ссылка = &Партнер)
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Контрагенты.Ссылка КАК гф_Контрагент,
	               |	Контрагенты.гф_Код КАК гф_Код,
	               |	Контрагенты.гф_ОсновнойКонтрагент КАК гф_ОсновнойКонтрагент,
	               |	Контрагенты.гф_Логистика КАК гф_Логистика,
	               |	Контрагенты.гф_RC_GLN_номер КАК гф_RC_GLN_номер,
	               |	Контрагенты.гф_Комментарий КАК гф_Комментарий,
	               |	Контрагенты.гф_Зарегистрирован КАК гф_Зарегистрирован
	               |ИЗ
	               |	ВТ_Контрагенты КАК ВТ_Контрагенты
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Контрагенты КАК Контрагенты
	               |		ПО ВТ_Контрагенты.Ссылка = Контрагенты.Ссылка
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	АдресаДоставки.Адрес КАК Адрес
	               |ИЗ
	               |	Справочник.Контрагенты.гф_АдресаДоставки КАК АдресаДоставки
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Контрагенты КАК ВТ_Контрагенты
	               |		ПО АдресаДоставки.Ссылка = ВТ_Контрагенты.Ссылка
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ОтветственныйМенеджер.Организация КАК Организация,
	               |	ОтветственныйМенеджер.Пользователь КАК Пользователь
	               |ИЗ
	               |	Справочник.Контрагенты.гф_ОтветственныйМенеджер КАК ОтветственныйМенеджер
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Контрагенты КАК ВТ_Контрагенты
	               |		ПО ОтветственныйМенеджер.Ссылка = ВТ_Контрагенты.Ссылка";
	
	Запрос.УстановитьПараметр("Партнер",Партнер.Ссылка);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	Выборка = РезультатЗапроса[1].Выбрать();

	Если Выборка.Следующий() Тогда
	
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);
		
		ЭтотОбъект["гф_АдресаДоставки"].Загрузить(РезультатЗапроса[2].Выгрузить());
		ЭтотОбъект["гф_ОтветственныйМенеджер"].Загрузить(РезультатЗапроса[3].Выгрузить());
	
	КонецЕсли;
	
КонецПроцедуры// } #wortmann

#КонецОбласти