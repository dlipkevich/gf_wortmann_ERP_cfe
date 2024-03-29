﻿#Область ОбработчикиСобытийФормы

// #wortmann {
// #4.2.03
// Прячем группу доступа, она создается автоматически
// Галфинд Окунев 2022/07/05
// 
// Параметры:
// Отказ				- Булево
// СтандартнаяОбработка	- Булево
&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	ИспользуютсяГруппыДоступаПартнеров = Ложь;  
	
	Элементы.ГруппаДоступаЧастноеЛицо.Видимость	= Ложь;
	Элементы.ГруппаДоступа.Видимость			= Ложь;
	
	Элементы.СтраницыПомощника.Высота = 43;  
	Элементы.СтраницыПомощника.РастягиватьПоВертикали = Ложь;
		
	Для Каждого Страница Из Элементы.СтраницыПомощника.ПодчиненныеЭлементы Цикл
		
		Страница.ВертикальнаяПрокруткаПриСжатии = Истина;
		
	КонецЦикла;	                                      
		
КонецПроцедуры// } #wortmann       

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// #wortmann {
// #4.2.03
// Прячем группу доступа, она создается автоматически
// Галфинд Окунев 2022/07/07
// 
// Параметры:
//  Форма	- ФормаКлиентскогоПриложения
&НаКлиентеНаСервереБезКонтекста
&После("УправлениеДоступностьюДополнительныеСведения")
Процедура гф_УправлениеДоступностьюДополнительныеСведения(Форма)
	
	Форма.Элементы.ГруппаДоступаЧастноеЛицо.Видимость	= Ложь;
	Форма.Элементы.ГруппаДоступа.Видимость				= Ложь;
	
КонецПроцедуры// } #wortmann

#КонецОбласти
